from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/users/', include('apps.users.urls')),
    path('api/household/', include('apps.household.urls')),
    path('accounts/', include('allauth.urls')),
]