import { Request, Response, NextFunction } from 'express';
import {
  getAllServices,
  getServiceById,
  getServiceBySlug,
  createService,
  updateService,
  deleteService,
  getCategories,
} from '../services/service.service';

export const listServices = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { category } = req.query;
    const services = await getAllServices(category as string);
    
    res.json({
      success: true,
      data: { services },
    });
  } catch (error) {
    next(error);
  }
};

export const listCategories = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const categories = await getCategories();
    
    res.json({
      success: true,
      data: { categories },
    });
  } catch (error) {
    next(error);
  }
};

export const getService = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const service = await getServiceById(id as string);
    
    res.json({
      success: true,
      data: { service },
    });
  } catch (error) {
    next(error);
  }
};

export const getServiceBySlugEndpoint = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { slug } = req.params;
    const service = await getServiceBySlug(slug as string);
    
    res.json({
      success: true,
      data: { service },
    });
  } catch (error) {
    next(error);
  }
};

// Admin only
export const createNewService = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const serviceData = req.body;
    const service = await createService(serviceData);
    
    res.status(201).json({
      success: true,
      message: 'Service created successfully',
      data: { service },
    });
  } catch (error) {
    next(error);
  }
};

export const updateExistingService = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updates = req.body;
    const service = await updateService(id as string, updates);
    
    res.json({
      success: true,
      message: 'Service updated successfully',
      data: { service },
    });
  } catch (error) {
    next(error);
  }
};

export const deleteExistingService = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    await deleteService(id as string);
    
    res.json({
      success: true,
      message: 'Service deleted successfully',
    });
  } catch (error) {
    next(error);
  }
};
