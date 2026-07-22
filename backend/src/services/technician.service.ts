import Technician, { ITechnician, IServiceOffering, IAvailability } from '../models/Technician';
import User from '../models/User';
import { createError } from '../middleware/errorHandler';
import mongoose from 'mongoose';

export const getTechnicianById = async (technicianId: string): Promise<ITechnician> => {
  const technician = await Technician.findById(technicianId)
    .populate('user', '-password')
    .populate('services.service');
    
  if (!technician) {
    throw createError('Technician not found', 404);
  }
  
  return technician;
};

export const getTechnicianByUserId = async (userId: string): Promise<ITechnician> => {
  const technician = await Technician.findOne({ user: userId })
    .populate('user', '-password')
    .populate('services.service');
    
  if (!technician) {
    throw createError('Technician profile not found', 404);
  }
  
  return technician;
};

export const createTechnicianProfile = async (
  userId: string,
  profileData: Partial<ITechnician>
): Promise<ITechnician> => {
  // Always ensure user role is technician
  await User.findByIdAndUpdate(userId, { role: 'technician' });

  // Upsert: update if exists, create if not
  const existing = await Technician.findOne({ user: userId });
  if (existing) {
    const { isApproved, approvalDate, rating, reviewCount, totalEarnings, totalJobs, ...allowedUpdates } = profileData as any;
    const updated = await Technician.findByIdAndUpdate(
      existing._id,
      allowedUpdates,
      { new: true, runValidators: true }
    ).populate('user', '-password').populate('services.service');
    return updated!;
  }

  const technician = await Technician.create({
    user: userId,
    ...profileData,
    isApproved: false,
  });

  return technician;
};

export const updateTechnicianProfile = async (
  technicianId: string,
  updateData: Partial<ITechnician>
): Promise<ITechnician> => {
  const { isApproved, approvalDate, rating, reviewCount, totalEarnings, totalJobs, ...allowedUpdates } = updateData;
  
  const technician = await Technician.findByIdAndUpdate(
    technicianId,
    allowedUpdates,
    { new: true, runValidators: true }
  ).populate('user', '-password').populate('services.service');
  
  if (!technician) {
    throw createError('Technician not found', 404);
  }
  
  return technician;
};

export const addServiceOffering = async (
  technicianId: string,
  serviceOffering: IServiceOffering
): Promise<ITechnician> => {
  const technician = await Technician.findById(technicianId);
  if (!technician) {
    throw createError('Technician not found', 404);
  }
  
  technician.services.push(serviceOffering);
  await technician.save();
  
  return technician.populate('services.service');
};

export const removeServiceOffering = async (
  technicianId: string,
  serviceId: string
): Promise<ITechnician> => {
  const technician = await Technician.findById(technicianId);
  if (!technician) {
    throw createError('Technician not found', 404);
  }
  
  technician.services = technician.services.filter(
    s => s.service.toString() !== serviceId
  );
  
  await technician.save();
  return technician.populate('services.service');
};

export const updateAvailability = async (
  technicianId: string,
  availability: IAvailability[]
): Promise<ITechnician> => {
  const technician = await Technician.findByIdAndUpdate(
    technicianId,
    { availability },
    { new: true }
  );
  
  if (!technician) {
    throw createError('Technician not found', 404);
  }
  
  return technician;
};

export const searchTechnicians = async (query: {
  service?: string;
  category?: string;
  lat?: number;
  lng?: number;
  radius?: number;
  isAvailable?: boolean;
  isApproved?: boolean;
  minRating?: number;
  page?: number;
  limit?: number;
}): Promise<{ technicians: ITechnician[]; total: number; page: number; pages: number }> => {
  const {
    service,
    category,
    lat,
    lng,
    radius,
    isAvailable,
    isApproved = true,
    minRating,
    page = 1,
    limit = 20,
  } = query;
  
  const filter: any = { isApproved };

  if (
    typeof lat === 'number' &&
    typeof lng === 'number' &&
    !Number.isNaN(lat) &&
    !Number.isNaN(lng)
  ) {
    const radiusKm = typeof radius === 'number' && radius > 0 ? Math.min(radius, 500) : 50;
    const maxMeters = radiusKm * 1000;
    const nearUserIds = await User.find({
      role: 'technician',
      location: {
        $nearSphere: {
          $geometry: { type: 'Point', coordinates: [lng, lat] },
          $maxDistance: maxMeters,
        },
      },
    })
      .distinct('_id')
      .exec();
    if (!nearUserIds.length) {
      return { technicians: [], total: 0, page, pages: 0 };
    }
    filter.user = { $in: nearUserIds };
  }

  if (typeof isAvailable === 'boolean') filter.isAvailable = isAvailable;
  if (minRating) filter.rating = { $gte: minRating };
  if (service) {
    // service is a MongoDB ObjectId
    filter['services.service'] = new mongoose.Types.ObjectId(service);
  } else if (category) {
    // category is a name string — look up matching service IDs first
    const Service = (await import('../models/Service')).default;
    const matchingServices = await Service.find({
      category: { $regex: new RegExp(category, 'i') }
    }).select('_id');
    if (matchingServices.length > 0) {
      filter['services.service'] = { $in: matchingServices.map(s => s._id) };
    } else {
      // No services found for this category — return empty
      return { technicians: [], total: 0, page, pages: 0 };
    }
  }
  
  const skip = (page - 1) * limit;
  
  const [technicians, total] = await Promise.all([
    Technician.find(filter)
      .populate('user', '-password')
      .populate('services.service')
      .skip(skip)
      .limit(limit)
      .sort({ rating: -1, totalJobs: -1 }),
    Technician.countDocuments(filter),
  ]);
  
  return {
    technicians,
    total,
    page,
    pages: Math.ceil(total / limit),
  };
};

export const approveTechnician = async (
  technicianId: string
): Promise<ITechnician> => {
  const technician = await Technician.findByIdAndUpdate(
    technicianId,
    {
      isApproved: true,
      approvalDate: new Date(),
    },
    { new: true }
  ).populate('user', '-password').populate('services.service');
  
  if (!technician) {
    throw createError('Technician not found', 404);
  }
  
  return technician;
};

export const updateTechnicianStats = async (
  technicianId: string,
  rating: number
): Promise<void> => {
  const technician = await Technician.findById(technicianId);
  if (!technician) return;
  
  // Calculate new average rating
  const newReviewCount = technician.reviewCount + 1;
  const newRating = ((technician.rating * technician.reviewCount) + rating) / newReviewCount;
  
  technician.rating = Math.round(newRating * 10) / 10;
  technician.reviewCount = newReviewCount;
  
  await technician.save();
};
