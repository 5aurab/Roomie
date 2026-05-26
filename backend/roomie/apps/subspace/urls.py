from django.urls import path
from .views import subspace_views

app_name = 'subspace'

urlpatterns = [
    # Space Routes
    path('<int:household_id>/spaces/', subspace_views.HouseholdSpaceListCreateView.as_view(), name='space-list-create'),
    path('<int:household_id>/spaces/<int:space_id>/', subspace_views.HouseholdSpaceDetailView.as_view(), name='space-detail'),
    path('<int:household_id>/spaces/<int:space_id>/release/', subspace_views.ReleaseSpaceToCommonView.as_view(), name='space-release'),

    # Subspace Routes
    path('<int:household_id>/subspaces/', subspace_views.SubspaceListCreateView.as_view(), name='subspace-list-create'),
    path('<int:household_id>/subspaces/<int:subspace_id>/', subspace_views.SubspaceDetailView.as_view(), name='subspace-detail'),
    path('<int:household_id>/subspaces/<int:subspace_id>/add-space/', subspace_views.AddSpaceToSubspaceView.as_view(), name='subspace-add-space'),
    path('<int:household_id>/subspaces/<int:subspace_id>/leave/', subspace_views.SubspaceLeaveView.as_view(), name='subspace-leave'),

    # Join & Invite Request Routes
    path('<int:household_id>/subspaces/<int:subspace_id>/invite/', subspace_views.SubspaceInviteView.as_view(), name='subspace-invite'),
    path('<int:household_id>/subspaces/<int:subspace_id>/join/', subspace_views.SubspaceJoinRequestView.as_view(), name='subspace-join-request'),
    path('<int:household_id>/subspaces/<int:subspace_id>/requests/<int:request_id>/respond/', subspace_views.SubspaceRespondRequestView.as_view(), name='subspace-respond-request'),
]