class ImageHelper
  def self.draw_scaled(image, window, scale_factor, x, y, z = 1)
    image.draw(x, y, z, scale_factor, scale_factor)
  end
end
