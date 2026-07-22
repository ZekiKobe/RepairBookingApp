import mongoose from 'mongoose';
import dotenv from 'dotenv';
import type { AdminAppRole } from './config/adminPermissions';
import Service from './models/Service';
import User from './models/User';
import Technician from './models/Technician';

dotenv.config();

async function ensureAdminAccount(params: {
  phone: string;
  password: string;
  firstName: string;
  lastName: string;
  adminRole: AdminAppRole;
  email?: string;
}) {
  const { phone, password, firstName, lastName, adminRole, email } = params;
  let doc = await User.findOne({ phone });
  if (!doc) {
    await User.create({
      phone,
      password,
      firstName,
      lastName,
      role: 'admin',
      adminRole,
      isVerified: true,
      isActive: true,
      ...(email ? { email } : {}),
    });
    console.log(`Created admin: ${phone} / ${password} (${adminRole})`);
    return;
  }
  doc.role = 'admin';
  doc.adminRole = adminRole;
  doc.firstName = firstName;
  doc.lastName = lastName;
  doc.isVerified = true;
  doc.isActive = true;
  doc.password = password;
  await doc.save();
  console.log(`Updated admin: ${phone} / ${password} (${adminRole})`);
}

const services = [
  {
    name: 'Plumbing Repair',
    description: 'Fix leaks, clogs, and pipe repairs',
    icon: 'pipe',
    category: 'plumbing',
    estimatedDuration: 60,
    basePrice: 50,
  },
  {
    name: 'Electrical Repair',
    description: 'Wiring, outlets, and electrical troubleshooting',
    icon: 'bolt',
    category: 'electrical',
    estimatedDuration: 90,
    basePrice: 75,
  },
  {
    name: 'House Cleaning',
    description: 'Deep cleaning and regular maintenance',
    icon: 'sparkles',
    category: 'cleaning',
    estimatedDuration: 120,
    basePrice: 60,
  },
  {
    name: 'AC Repair',
    description: 'Air conditioning installation and repair',
    icon: 'snowflake',
    category: 'appliance_repair',
    estimatedDuration: 90,
    basePrice: 80,
  },
  {
    name: 'Refrigerator Repair',
    description: 'Fridge cooling and compressor issues',
    icon: 'refrigerator',
    category: 'appliance_repair',
    estimatedDuration: 75,
    basePrice: 70,
  },
  {
    name: 'Washing Machine Repair',
    description: 'Washer and dryer repairs',
    icon: 'washer',
    category: 'appliance_repair',
    estimatedDuration: 60,
    basePrice: 65,
  },
];

const seedDatabase = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/repair_booking');
    console.log('Connected to MongoDB');
    
    // Clear existing services
    await Service.deleteMany({});
    console.log('Cleared existing services');
    
    // Insert services
    const createdServices = await Service.insertMany(
      services.map(s => ({ ...s, slug: s.name.toLowerCase().replace(/\s+/g, '-') }))
    );
    console.log(`Created ${createdServices.length} services`);
    
    // Admin accounts for the web admin portal (login with phone + password)
    const superPhone = process.env.SEED_ADMIN_PHONE || '0912345678';
    const superPass = process.env.SEED_ADMIN_PASSWORD || 'admin123';
    await ensureAdminAccount({
      phone: superPhone,
      password: superPass,
      firstName: 'Super',
      lastName: 'Admin',
      adminRole: 'super_admin',
      ...(process.env.SEED_ADMIN_EMAIL ? { email: process.env.SEED_ADMIN_EMAIL } : {}),
    });

    const roPhone = process.env.SEED_ADMIN_READONLY_PHONE || '0912345679';
    const roPass = process.env.SEED_ADMIN_READONLY_PASSWORD || 'admin123';
    await ensureAdminAccount({
      phone: roPhone,
      password: roPass,
      firstName: 'ReadOnly',
      lastName: 'Admin',
      adminRole: 'read_only',
      email: 'readonly@repairbooking.local',
    });
    // Create admin user if doesn't exist
    const adminExists = await User.findOne({ phone: '0912345678' });
    if (!adminExists) {
      await User.create({
        phone: '0912345678',
        password: 'admin123',
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin',
        isVerified: true,
      });
      console.log('Created admin user: 0912345678 / admin123');
    }
    
    // Sample technicians data
    const technicianSeeds = [
      {
        phone: '0998765432', password: 'tech123',
        firstName: 'John', lastName: 'Bekele',
        bio: 'Expert plumber and electrician with 5 years experience in Addis Ababa.',
        yearsOfExperience: 5,
        serviceIndices: [0, 1], // Plumbing, Electrical
      },
      {
        phone: '0998765433', password: 'tech123',
        firstName: 'Sara', lastName: 'Tadesse',
        bio: 'Professional cleaner specializing in deep home cleaning.',
        yearsOfExperience: 3,
        serviceIndices: [2], // Cleaning
      },
      {
        phone: '0998765434', password: 'tech123',
        firstName: 'Dawit', lastName: 'Haile',
        bio: 'AC and appliance repair specialist, certified technician.',
        yearsOfExperience: 7,
        serviceIndices: [3, 4, 5], // AC, Fridge, Washer
      },
      {
        phone: '0998765435', password: 'tech123',
        firstName: 'Meron', lastName: 'Girma',
        bio: 'Multi-skilled home repair expert, available weekdays.',
        yearsOfExperience: 4,
        serviceIndices: [0, 2, 3], // Plumbing, Cleaning, AC
      },
    ];

    const availability = [
      { day: 'monday',    slots: [{ start: '08:00', end: '17:00' }] },
      { day: 'tuesday',   slots: [{ start: '08:00', end: '17:00' }] },
      { day: 'wednesday', slots: [{ start: '08:00', end: '17:00' }] },
      { day: 'thursday',  slots: [{ start: '08:00', end: '17:00' }] },
      { day: 'friday',    slots: [{ start: '08:00', end: '15:00' }] },
    ];

    for (const seed of technicianSeeds) {
      let techUser = await User.findOne({ phone: seed.phone });
      if (!techUser) {
        techUser = await User.create({
          phone: seed.phone,
          password: seed.password,
          firstName: seed.firstName,
          lastName: seed.lastName,
          role: 'technician',
          isVerified: true,
        });
      }
      const existingTech = await Technician.findOne({ user: techUser._id });
      if (!existingTech) {
        await Technician.create({
          user: techUser._id,
          bio: seed.bio,
          services: seed.serviceIndices.map(i => ({
            service: createdServices[i]._id,
            price: createdServices[i].basePrice + 20,
            description: createdServices[i].description,
          })),
          availability,
          isAvailable: true,
          isApproved: true,
          approvalDate: new Date(),
          yearsOfExperience: seed.yearsOfExperience,
          rating: parseFloat((3.5 + Math.random() * 1.5).toFixed(1)),
          reviewCount: Math.floor(Math.random() * 40) + 5,
        });
        console.log(`Created technician: ${seed.phone} / ${seed.password}`);
      } else {
        // Ensure existing technician is approved
        await Technician.findByIdAndUpdate(existingTech._id, { isApproved: true, isAvailable: true, availability });
        console.log(`Updated technician: ${seed.phone}`);
      }
    }
    
    // Create sample regular user
    const userExists = await User.findOne({ phone: '0911122334' });
    if (!userExists) {
      await User.create({
        phone: '0911122334',
        password: 'user123',
        firstName: 'Jane',
        lastName: 'Customer',
        role: 'user',
        isVerified: true,
      });
      console.log('Created sample user: 0911122334 / user123');
    }
    
    console.log('\nSeed completed successfully!');
    console.log('\n── Admin portal (http://localhost:5173) ──');
    console.log(`Super admin:  ${superPhone} / ${superPass}`);
    console.log(`Read-only admin: ${roPhone} / ${roPass}`);
    console.log('\n── Mobile / API sample accounts ──');
    console.log('\nSample accounts:');
    console.log('Admin: 0912345678 / admin123');
    console.log('Technician: 0998765432 / tech123');
    console.log('User: 0911122334 / user123');
    
  } catch (error) {
    console.error('Seed error:', error);
  } finally {
    await mongoose.disconnect();
  }
};

seedDatabase();
