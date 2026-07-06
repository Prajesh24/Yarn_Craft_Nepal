import { ProductRepository } from '../repositories/product.repository';
import { CreateProductDTO, UpdateProductDTO } from '../dtos/product.dto';
import { HttpError } from '../errors/http-error';

const productRepository = new ProductRepository();

export class ProductService {
  async createProduct(data: CreateProductDTO) {
    return await productRepository.createProduct(data);
  }

  async getAllProducts() {
    return await productRepository.getAllProducts();
  }

  async getProductById(id: string) {
    const product = await productRepository.getProductById(id);
    if (!product) {
      throw new HttpError(404, 'Product not found');
    }
    return product;
  }

  async updateProduct(id: string, data: UpdateProductDTO) {
    const product = await productRepository.updateProduct(id, data);
    if (!product) {
      throw new HttpError(404, 'Product not found');
    }
    return product;
  }

  async deleteProduct(id: string) {
    const deleted = await productRepository.deleteProduct(id);
    if (!deleted) {
      throw new HttpError(404, 'Product not found');
    }
  }
}
