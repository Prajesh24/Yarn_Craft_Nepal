import { Request, Response } from 'express';
import { ProductService } from '../services/product.service';
import { CreateProductDTO, UpdateProductDTO } from '../dtos/product.dto';
import z from 'zod';

const productService = new ProductService();

export class ProductController {
  async createProduct(req: Request, res: Response) {
    try {
      const body = { ...req.body };
      // Parse numeric fields sent as form strings (multipart/form-data)
      if (body.price !== undefined) body.price = Number(body.price);
      if (body.quantity !== undefined) body.quantity = Number(body.quantity);
      // Colors arrive as a comma-separated string from the multipart form.
      if (typeof body.colors === 'string') {
        body.colors = body.colors
          .split(',')
          .map((c: string) => c.trim())
          .filter((c: string) => c.length > 0);
      }
      const parsedData = CreateProductDTO.safeParse(body);
      if (!parsedData.success) {
        return res.status(400).json({ success: false, message: z.prettifyError(parsedData.error) });
      }
      if (req.file) parsedData.data.imageUrl = `/uploads/${req.file.filename}`;
      const product = await productService.createProduct(parsedData.data);
      return res.status(201).json({ success: true, data: product, message: 'Product created' });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async getProducts(req: Request, res: Response) {
    try {
      const products = await productService.getAllProducts();
      return res.status(200).json({ success: true, data: products });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async getProductById(req: Request<{ id: string }>, res: Response) {
    try {
      const product = await productService.getProductById(req.params.id);
      return res.status(200).json({ success: true, data: product });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async updateProduct(req: Request<{ id: string }>, res: Response) {
    try {
      const body = { ...req.body };
      if (body.price !== undefined) body.price = Number(body.price);
      if (body.quantity !== undefined) body.quantity = Number(body.quantity);
      // Colors arrive as a comma-separated string from the multipart form.
      if (typeof body.colors === 'string') {
        body.colors = body.colors
          .split(',')
          .map((c: string) => c.trim())
          .filter((c: string) => c.length > 0);
      }
      const parsedData = UpdateProductDTO.safeParse(body);
      if (!parsedData.success) {
        return res.status(400).json({ success: false, message: z.prettifyError(parsedData.error) });
      }
      if (req.file) parsedData.data.imageUrl = `/uploads/${req.file.filename}`;
      const product = await productService.updateProduct(req.params.id, parsedData.data);
      return res.status(200).json({ success: true, data: product, message: 'Product updated' });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }

  async deleteProduct(req: Request<{ id: string }>, res: Response) {
    try {
      await productService.deleteProduct(req.params.id);
      return res.status(200).json({ success: true, message: 'Product deleted' });
    } catch (error: any) {
      return res.status(error.statusCode ?? 500).json({ success: false, message: error.message || 'Internal Server Error' });
    }
  }
}
