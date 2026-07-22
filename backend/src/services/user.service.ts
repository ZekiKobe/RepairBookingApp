import User, { IUser, ILocation } from '../models/User';
import { createError } from '../middleware/errorHandler';

export const getUserById = async (userId: string): Promise<IUser> => {
  const user = await User.findById(userId);
  if (!user) {
    throw createError('User not found', 404);
  }
  return user;
};

export const updateUser = async (
  userId: string,
  updateData: Partial<IUser>
): Promise<IUser> => {
  const { password, role, isActive, ...allowedUpdates } = updateData;
  
  const user = await User.findByIdAndUpdate(
    userId,
    allowedUpdates,
    { new: true, runValidators: true }
  );
  
  if (!user) {
    throw createError('User not found', 404);
  }
  
  return user;
};

export const updateLocation = async (
  userId: string,
  location: ILocation
): Promise<IUser> => {
  const user = await User.findByIdAndUpdate(
    userId,
    { location },
    { new: true }
  );
  
  if (!user) {
    throw createError('User not found', 404);
  }
  
  return user;
};

export const deleteUser = async (userId: string): Promise<void> => {
  const user = await User.findByIdAndDelete(userId);
  if (!user) {
    throw createError('User not found', 404);
  }
};

export const searchUsers = async (query: {
  phone?: string;
  email?: string;
  role?: string;
  isActive?: boolean;
  page?: number;
  limit?: number;
}): Promise<{ users: IUser[]; total: number; page: number; pages: number }> => {
  const { phone, email, role, isActive, page = 1, limit = 20 } = query;
  
  const filter: any = {};
  
  if (phone) filter.phone = { $regex: phone, $options: 'i' };
  if (email) filter.email = { $regex: email, $options: 'i' };
  if (role) filter.role = role;
  if (typeof isActive === 'boolean') filter.isActive = isActive;
  
  const skip = (page - 1) * limit;
  
  const [users, total] = await Promise.all([
    User.find(filter).skip(skip).limit(limit).sort({ createdAt: -1 }),
    User.countDocuments(filter),
  ]);
  
  return {
    users,
    total,
    page,
    pages: Math.ceil(total / limit),
  };
};
