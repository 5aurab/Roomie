from django.urls import path
from apps.subspace.views.subspace_views import (
    HouseholdSpaceListCreateView,
    HouseholdSpaceDetailView,
    ReleaseSpaceToCommonView,
    SubspaceListCreateView,
    SubspaceDetailView,
    AddSpaceToSubspaceView,
    SubspaceLeaveView,
    SubspaceInviteView,
    SubspaceJoinRequestView,
    SubspaceRespondRequestView,
    SubspacePendingRequestsView,
)
app_name = 'subspace'

urlpatterns = [
    # Space Routes
    path('<int:household_id>/spaces/', HouseholdSpaceListCreateView.as_view(), name='space-list-create'),
    path('<int:household_id>/spaces/<int:space_id>/', HouseholdSpaceDetailView.as_view(), name='space-detail'),
    path('<int:household_id>/spaces/<int:space_id>/release/', ReleaseSpaceToCommonView.as_view(), name='space-release'),

    # Subspace Routes
    path('<int:household_id>/subspaces/', SubspaceListCreateView.as_view(), name='subspace-list-create'),
    path('<int:household_id>/subspaces/<int:subspace_id>/', SubspaceDetailView.as_view(), name='subspace-detail'),
    path('<int:household_id>/subspaces/<int:subspace_id>/add-space/', AddSpaceToSubspaceView.as_view(), name='subspace-add-space'),
    path('<int:household_id>/subspaces/<int:subspace_id>/leave/', SubspaceLeaveView.as_view(), name='subspace-leave'),

    # Join & Invite Request Routes
    path('<int:household_id>/subspaces/<int:subspace_id>/invite/', SubspaceInviteView.as_view(), name='subspace-invite'),
    path('<int:household_id>/subspaces/<int:subspace_id>/join/',    SubspaceJoinRequestView.as_view(), name='subspace-join-request'),
    path('<int:household_id>/subspaces/<int:subspace_id>/requests/<int:request_id>/respond/', SubspaceRespondRequestView.as_view(), name='subspace-respond-request'),
    path('<int:household_id>/subspaces/<int:subspace_id>/requests/', SubspacePendingRequestsView.as_view(), name='subspace-pending-requests'),
]    