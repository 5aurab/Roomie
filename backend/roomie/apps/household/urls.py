from django.urls import path
from .views import (
    CreateHouseholdView,
    JoinHouseholdView,
    HouseholdDetailView,
    LeaveHouseholdView,
)

urlpatterns = [
    path('create/', CreateHouseholdView.as_view(), name='create-household'),
    path('join/', JoinHouseholdView.as_view(), name='join-household'),
    path('my/', HouseholdDetailView.as_view(), name='my-households'),
    path('<int:household_id>/leave/', LeaveHouseholdView.as_view(), name='leave-household'),
]