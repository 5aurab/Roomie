from django.db import models
from django.conf import settings
from django.utils import timezone
from datetime import timedelta


class HouseholdSpace(models.Model):
    household = models.ForeignKey(
        'household.Household',
        on_delete=models.CASCADE,
        related_name='spaces'
    )
    name = models.CharField(max_length=100)
    subspace = models.ForeignKey(
        'Subspace',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='spaces'
    )

    def __str__(self):
        return f"{self.name} - {self.household}"


class Subspace(models.Model):
    household = models.ForeignKey(
        'household.Household',
        on_delete=models.CASCADE,
        related_name='subspaces'
    )
    name = models.CharField(max_length=100)
    is_individual = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.name} - {self.household}"


class SubspaceMember(models.Model):
    STATUS_CHOICES = [
        ('active', 'Active'),
        ('pending', 'Pending'),
    ]
    subspace = models.ForeignKey(
        Subspace,
        on_delete=models.CASCADE,
        related_name='members'
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='subspace_memberships'
    )
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='active')

    class Meta:
        unique_together = ('subspace', 'user')

    def __str__(self):
        return f"{self.user} - {self.subspace}"


class SubspaceJoinRequest(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('declined', 'Declined'),
        ('expired', 'Expired'),
    ]
    subspace = models.ForeignKey(
        Subspace,
        on_delete=models.CASCADE,
        related_name='join_requests'
    )
    requested_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='subspace_requests_sent'
    )
    invited_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='subspace_invites_sent'
    )
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()

    def save(self, *args, **kwargs):
        if not self.pk:
            self.expires_at = timezone.now() + timedelta(hours=24)
        super().save(*args, **kwargs)

    def is_expired(self):
        return timezone.now() > self.expires_at

    def __str__(self):
        return f"{self.requested_by} → {self.subspace}"