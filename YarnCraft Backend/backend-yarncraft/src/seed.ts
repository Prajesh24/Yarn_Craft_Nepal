/**
 * Seeds the database with sample products (and an admin user) so the
 * Flutter app has real data to display.
 *
 * Run with:  npm run seed
 */
import bcryptjs from 'bcryptjs';

import { connectDatabase } from './database/mongodb';
import { ProductModel } from './models/product.model';
import { UserModel } from './models/user.model';
import mongoose from 'mongoose';

const products = [
  {
    name: 'Hand-loomed Organic Hemp Fabric',
    description: 'Pokhara Valley',
    category: 'Hemp',
    price: 1200,
    quantity: 40,
    imageUrl: '',
  },
  {
    name: 'Indigo Dyed Hemp Canvas',
    description: 'Kathmandu',
    category: 'Hemp',
    price: 2500,
    quantity: 25,
    imageUrl: '',
  },
  {
    name: 'Raw Hemp Fiber Blend',
    description: 'Lalitpur',
    category: 'Hemp',
    price: 950,
    quantity: 60,
    imageUrl: '',
  },
  {
    name: 'Fine Weave Apparel Hemp',
    description: 'Bhaktapur',
    category: 'Hemp',
    price: 1800,
    quantity: 30,
    imageUrl: '',
  },
  {
    name: 'Organic Cotton Skein',
    description: 'Bhaktapur Weavers',
    category: 'Hand-spun Yarn',
    price: 1200,
    quantity: 50,
    imageUrl: '',
  },
  {
    name: 'Pure Pashmina',
    description: 'Himalayan',
    category: 'Pashmina',
    price: 8500,
    quantity: 12,
    imageUrl: '',
  },
  {
    name: 'Natural Hemp Roll',
    description: 'Pokhara Looms',
    category: 'Hemp',
    price: 2100,
    quantity: 18,
    imageUrl: '',
  },
  {
    name: 'Pure Dhaka Silk Wrap',
    description: 'Tehrathum, Nepal',
    category: 'Silk',
    price: 4500,
    quantity: 15,
    imageUrl: '',
  },
  {
    name: 'Highland Merino Wool',
    description: 'Mustang',
    category: 'Wool',
    price: 3200,
    quantity: 22,
    imageUrl: '',
  },
  {
    name: 'Hand-spun Nettle Yarn',
    description: 'Ilam Hills',
    category: 'Hand-spun Yarn',
    price: 1450,
    quantity: 35,
    imageUrl: '',
  },
  {
    name: 'Soft Cashmere Pashmina Shawl',
    description: 'Kathmandu',
    category: 'Pashmina',
    price: 9800,
    quantity: 8,
    imageUrl: '',
  },
  {
    name: 'Mulberry Silk Thread',
    description: 'Dharan',
    category: 'Silk',
    price: 5200,
    quantity: 14,
    imageUrl: '',
  },
];

async function seed() {
  await connectDatabase();

  // ── Products ────────────────────────────────────────────────────────────
  await ProductModel.deleteMany({});

  // Attach category-themed images (3 each) served locally from /uploads.
  // Stored as relative paths so the Flutter client resolves them against
  // whichever host it runs on (e.g. 10.0.2.2 on the Android emulator).
  // The 3 images double as the colour variants on the product page.
  const categorySlug: Record<string, string> = {
    Hemp: 'hemp',
    Pashmina: 'pashmina',
    Silk: 'silk',
    Wool: 'wool',
    'Hand-spun Yarn': 'yarn',
  };

  const withImages = products.map((p) => {
    const slug = categorySlug[p.category ?? ''] ?? 'yarn';
    const images = [1, 2, 3].map((n) => `/uploads/${slug}-${n}.jpg`);
    return {
      ...p,
      imageUrl: p.imageUrl && p.imageUrl.length > 0 ? p.imageUrl : images[0],
      images,
    };
  });

  const created = await ProductModel.insertMany(withImages);
  console.log(`✅ Seeded ${created.length} products`);

  // ── Admin user (idempotent) ───────────────────────────────────────────────
  const adminEmail = 'admin@yarncraft.com';
  const existingAdmin = await UserModel.findOne({ email: adminEmail });
  if (!existingAdmin) {
    const hashed = await bcryptjs.hash('admin123', 12);
    await UserModel.create({
      name: 'YarnCraft Admin',
      email: adminEmail,
      password: hashed,
      role: 'admin',
    });
    console.log(`✅ Created admin user (${adminEmail} / admin123)`);
  } else {
    console.log(`ℹ️  Admin user already exists (${adminEmail})`);
  }

  await mongoose.connection.close();
  console.log('🌱 Seed complete.');
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});
