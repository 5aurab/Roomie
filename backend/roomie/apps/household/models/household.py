from django.db import models
from django.conf import settings
import uuid


class Household(models.Model):
    name = models.CharField(max_length=100)
    address = models.TextField(blank=True)
    no_of_rooms = models.PositiveIntegerField(default=1)
    move_in_date = models.DateField(null=True, blank=True)
    join_code = models.CharField(max_length=8, unique=True, blank=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        related_name='created_households'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.join_code:
            self.join_code = uuid.uuid4().hex[:8].upper()
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class HouseholdMember(models.Model):
    household = models.ForeignKey(
        Household,
        on_delete=models.CASCADE,
        related_name='members'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='households'
    )
    move_in_date = models.DateField(null=True, blank=True)
    joined_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('household', 'user')

    def __str__(self):
        return f"{self.user} - {self.household}"