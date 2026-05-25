from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    display_name = models.CharField(max_length=50, blank=True)
    dob = models.DateField(null=True, blank=True)

  
    VIBE_CHOICES=[
            ('available', 'Available'),
            ('busy', 'Busy'),
            ('exam', 'Taking Exam'),
            ('sick', 'Sick'),
            ('vacation', 'On Vacation'),
    ]
    status_vibe =models.CharField(
        max_length=20,
        choices=VIBE_CHOICES,
        default='available'
    )
    
    

    is_email_verified = models.BooleanField(default=False)
    password_reset_code = models.CharField(max_length=6, blank=True, null=True)
    
    def __str__(self):
        return self.display_name or self.username
    