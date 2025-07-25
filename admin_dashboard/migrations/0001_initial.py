# Generated by Django 5.2 on 2025-06-19 14:36

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Disease',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('disease_name', models.CharField(max_length=255, unique=True)),
                ('cure', models.TextField()),
                ('commonness', models.CharField(blank=True, max_length=255, null=True)),
                ('crop_name', models.CharField(blank=True, max_length=255, null=True)),
            ],
        ),
        migrations.CreateModel(
            name='News',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('title', models.CharField(max_length=255)),
                ('subtitle', models.CharField(blank=True, max_length=255, null=True)),
                ('content', models.TextField()),
                ('author_name', models.CharField(max_length=255)),
                ('timestamp', models.DateTimeField(auto_now_add=True)),
            ],
        ),
        migrations.CreateModel(
            name='Tip',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('crop_name', models.CharField(max_length=255, unique=True)),
                ('crop_tips', models.TextField()),
            ],
        ),
    ]
