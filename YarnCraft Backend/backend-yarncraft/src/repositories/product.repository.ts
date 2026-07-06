import { ProductModel, IProduct } from '../models/product.model';

export class ProductRepository {
  async createProduct(data: any): Promise<IProduct> {
    return await ProductModel.create(data);
  }

  async getAllProducts(): Promise<IProduct[]> {
    return await ProductModel.find().exec();
  }

  async getProductById(id: string): Promise<IProduct | null> {
    return await ProductModel.findById(id).exec();
  }

  async updateProduct(id: string, data: any): Promise<IProduct | null> {
    return await ProductModel.findByIdAndUpdate(id, data, { new: true }).exec();
  }

  async deleteProduct(id: string): Promise<boolean> {
    const result = await ProductModel.findByIdAndDelete(id).exec();
    return result !== null;
  }
}
