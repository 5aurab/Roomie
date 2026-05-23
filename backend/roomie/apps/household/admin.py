from django.contrib import admin
from  .models.household import Household, HouseholdMember

admin.site.register(Household)
admin.site.register(HouseholdMember)
