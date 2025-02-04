from django.db import models

# Tips Model
class Tip(models.Model):
    crop_name = models.CharField(max_length=255, unique=True)  # Unique crop name
    crop_tips = models.TextField()  # Tips for that crop

    def __str__(self):
        return self.crop_name


# Diseases Model
class Disease(models.Model):
    disease_name = models.CharField(max_length=255, unique=True)
    cure = models.TextField()
    commonness = models.CharField(max_length=255, blank=True, null=True)  # Optional field

    def __str__(self):
        return self.disease_name


# News Model
class News(models.Model):
    title = models.CharField(max_length=255)
    subtitle = models.CharField(max_length=255, blank=True, null=True)  # Optional
    content = models.TextField()
    author_name = models.CharField(max_length=255)
    timestamp = models.DateTimeField(auto_now_add=True)  # Auto-created timestamp

    def __str__(self):
        return self.title
