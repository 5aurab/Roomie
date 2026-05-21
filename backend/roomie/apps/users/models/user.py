
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    display_name = models.CharField(max_length=50, blank=True)
    dob = models.DateField(null=True, blank=True)
    profile_status = models.CharField(
        max_length=20,
        choices=[
            ('available', 'Available'),
            ('busy', 'Busy'),
            ('exam', 'Taking Exam'),
            ('sick', 'Sick'),
        ],
        default='available'
    )
    is_email_verified = models.BooleanField(default=False)
    firebase_uid = models.CharField(max_length=128, unique=True, null=True, blank=True)
    # Google login, firebase uid will be used to store

    def __str__(self):
        return self.display_name or self.username
