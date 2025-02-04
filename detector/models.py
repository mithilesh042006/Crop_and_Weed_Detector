from django.db import models
from authentication.models import CustomUser  # Import your CustomUser model

class ImageRecord(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, null=True, blank=True)  # Tracks which user uploaded the image
    image_data = models.ImageField(upload_to='uploaded_images/', null=True, blank=True)
    processed_image = models.ImageField(upload_to='processed_images/', null=True, blank=True)
    model_chosen = models.CharField(max_length=100, default="default_model")
    summary = models.TextField(null=True, blank=True, default="Detected species placeholder")
    crop_name = models.CharField(max_length=100, default="Unknown Crop")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"ImageRecord (ID={self.id}, User={self.user.username}, Model={self.model_chosen})"
