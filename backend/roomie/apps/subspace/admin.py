from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models.subspace import HouseholdSpace, Subspace, SubspaceMember, SubspaceJoinRequest

admin.site.register(HouseholdSpace)
admin.site.register(Subspace)
admin.site.register(SubspaceMember)
admin.site.register(SubspaceJoinRequest)