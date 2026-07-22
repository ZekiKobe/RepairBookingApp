import Service, { IService } from '../models/Service';
import { createError } from '../middleware/errorHandler';

export const getAllServices = async (category?: string): Promise<IService[]> => {
  const filter: any = { isActive: true };
  if (category) filter.category = category;
  
  return await Service.find(filter).sort({ name: 1 });
};

export const getServiceById = async (serviceId: string): Promise<IService> => {
  const service = await Service.findById(serviceId);
  
  if (!service) {
    throw createError('Service not found', 404);
  }
  
  return service;
};

export const getServiceBySlug = async (slug: string): Promise<IService> => {
  const service = await Service.findOne({ slug, isActive: true });
  
  if (!service) {
    throw createError('Service not found', 404);
  }
  
  return service;
};

export const createService = async (serviceData: {
  name: string;
  description?: string;
  icon?: string;
  category: string;
  estimatedDuration?: number;
  basePrice?: number;
}): Promise<IService> => {
  const slug = serviceData.name.toLowerCase().replace(/\s+/g, '-').replace(/[^a-z0-9-]/g, '');
  
  // Check if slug exists
  const existing = await Service.findOne({ slug });
  if (existing) {
    throw createError('Service with similar name already exists', 400);
  }
  
  const service = await Service.create({
    ...serviceData,
    slug,
  });
  
  return service;
};

export const updateService = async (
  serviceId: string,
  updateData: Partial<IService>
): Promise<IService> => {
  const service = await Service.findByIdAndUpdate(
    serviceId,
    updateData,
    { new: true, runValidators: true }
  );
  
  if (!service) {
    throw createError('Service not found', 404);
  }
  
  return service;
};

export const deleteService = async (serviceId: string): Promise<void> => {
  const service = await Service.findByIdAndDelete(serviceId);
  
  if (!service) {
    throw createError('Service not found', 404);
  }
};

export const getCategories = async (): Promise<string[]> => {
  const categories = await Service.distinct('category', { isActive: true });
  return categories;
};
