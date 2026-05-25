from django.urls import path
from .views import (
    CreateHouseholdView,
    JoinHouseholdView,
    HouseholdDetailView,
    LeaveHouseholdView,
    HouseholdMembersView,
    UpdateHouseholdView
)

urlpatterns = [
    path('create/', CreateHouseholdView.as_view(), name='create-household'),
    path('join/', JoinHouseholdView.as_view(), name='join-household'),
    path('my/', HouseholdDetailView.as_view(), name='my-households'),
    path('<int:household_id>/leave/', LeaveHouseholdView.as_view(), name='leave-household'),
    path('<int:household_id>/members/', HouseholdMembersView.as_view(), name='household-members'),
    path('<int:household_id>/update/', UpdateHouseholdView.as_view(), name='update-household'),
]