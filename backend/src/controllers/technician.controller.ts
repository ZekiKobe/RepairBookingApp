import { Request, Response, NextFunction } from 'express';
import { AuthRequest } from '../middleware/auth';
import {
  getTechnicianById,
  getTechnicianByUserId,
  createTechnicianProfile,
  updateTechnicianProfile,
  addServiceOffering,
  removeServiceOffering,
  updateAvailability,
  searchTechnicians,
  approveTechnician,
} from '../services/technician.service';
import Technician from '../models/Technician';

export const getMyTechnicianProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const technician = await getTechnicianByUserId(req.user!._id.toString());
    
    res.json({
      success: true,
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

export const createProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const profileData = req.body;
    const existing = await (await import('../models/Technician')).default.findOne({ user: req.user!._id });
    const technician = await createTechnicianProfile(req.user!._id.toString(), profileData);
    const statusCode = existing ? 200 : 201;
    res.status(statusCode).json({
      success: true,
      message: existing ? 'Technician profile updated successfully.' : 'Technician profile created successfully. Pending approval.',
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

export const updateProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updates = req.body;
    
    const technician = await updateTechnicianProfile(id as string, updates);
    
    res.json({
      success: true,
      message: 'Technician profile updated successfully',
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

export const addService = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const serviceOffering = req.body;
    
    const technician = await addServiceOffering(id as string, serviceOffering);
    
    res.json({
      success: true,
      message: 'Service added successfully',
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

export const removeService = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id, serviceId } = req.params;
    
    const technician = await removeServiceOffering(id as string, serviceId as string);
    
    res.json({
      success: true,
      message: 'Service removed successfully',
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

export const setAvailability = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const { availability } = req.body;
    
    const technician = await updateAvailability(id as string, availability);
    
    res.json({
      success: true,
      message: 'Availability updated successfully',
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

export const listTechnicians = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { service, category, lat, lng, isAvailable, minRating, page, limit } = req.query;
    
    const result = await searchTechnicians({
      service: service as string,
      category: category as string,
      lat: lat ? parseFloat(lat as string) : undefined,
      lng: lng ? parseFloat(lng as string) : undefined,
      isAvailable: isAvailable !== undefined ? isAvailable === 'true' : undefined,
      isApproved: true,
      minRating: minRating ? parseFloat(minRating as string) : undefined,
      page: page ? parseInt(page as string) : 1,
      limit: limit ? parseInt(limit as string) : 20,
    });
    
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

export const getTechnician = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const technician = await getTechnicianById(id as string);
    
    res.json({
      success: true,
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

// Admin only
export const approveTechnicianProfile = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const technician = await approveTechnician(id as string);
    
    res.json({
      success: true,
      message: 'Technician approved successfully',
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

export const setTechnicianSuspended = async (req: AuthRequest, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const { suspended } = req.body as { suspended?: boolean };
    if (typeof suspended !== 'boolean') {
      res.status(400).json({ success: false, message: 'suspended (boolean) is required' });
      return;
    }
    const technician = await Technician.findByIdAndUpdate(id, { isSuspended: suspended }, { new: true }).populate({
      path: 'user',
      select: '-password',
    });
    if (!technician) {
      res.status(404).json({ success: false, message: 'Technician not found' });
      return;
    }
    res.json({
      success: true,
      message: suspended ? 'Technician suspended' : 'Technician unsuspended',
      data: { technician },
    });
  } catch (error) {
    next(error);
  }
};

export const listPendingTechnicians = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { page, limit } = req.query;
    
    const result = await searchTechnicians({
      isApproved: false,
      page: page ? parseInt(page as string) : 1,
      limit: limit ? parseInt(limit as string) : 20,
    });
    
    res.json({
      success: true,
      data: result,
    });
  } catch (error) {
    next(error);
  }
};
