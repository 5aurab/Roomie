from django.utils import timezone
from rest_framework import status, views, response, permissions
from ..models.subspace import HouseholdSpace, Subspace, SubspaceMember, SubspaceJoinRequest
from ..serializers.subspace_serializers import (
    HouseholdSpaceSerializer,
    SubspaceSerializer,
    SubspaceMemberSerializer,
    SubspaceJoinRequestSerializer,
)
from apps.household.models.household import HouseholdMember


def is_household_member(user, household_id):
    return HouseholdMember.objects.filter(
        household_id=household_id,
        user=user
    ).exists()


def is_subspace_member(user, subspace_id):
    return SubspaceMember.objects.filter(
        subspace_id=subspace_id,
        user=user,
        status='active'
    ).exists()


# ─── SPACE VIEWS ───────────────────────────────────────────

class HouseholdSpaceListCreateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, household_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        spaces = HouseholdSpace.objects.filter(household_id=household_id)
        return response.Response(
            HouseholdSpaceSerializer(spaces, many=True).data
        )

    def post(self, request, household_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        serializer = HouseholdSpaceSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(household_id=household_id)
            return response.Response(serializer.data, status=status.HTTP_201_CREATED)
        return response.Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class HouseholdSpaceDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, household_id, space_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        try:
            space = HouseholdSpace.objects.get(id=space_id, household_id=household_id)
        except HouseholdSpace.DoesNotExist:
            return response.Response(
                {'error': 'Space not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        space.delete()
        return response.Response({'message': 'Space deleted'}, status=status.HTTP_200_OK)


class ReleaseSpaceToCommonView(views.APIView):
    """
    Releases a space from a subspace, returning it to the common household area.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, household_id, space_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        try:
            space = HouseholdSpace.objects.get(id=space_id, household_id=household_id)
        except HouseholdSpace.DoesNotExist:
            return response.Response(
                {'error': 'Space not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        space.subspace = None
        space.save()
        return response.Response(
            HouseholdSpaceSerializer(space).data,
            status=status.HTTP_200_OK
        )


# ─── SUBSPACE VIEWS ────────────────────────────────────────

class SubspaceListCreateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, household_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        subspaces = Subspace.objects.filter(household_id=household_id)
        return response.Response(
            SubspaceSerializer(subspaces, many=True).data
        )

    def post(self, request, household_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        serializer = SubspaceSerializer(data=request.data)
        if serializer.is_valid():
            subspace = serializer.save(household_id=household_id)
            
            # Automatically add the creator as an active member of the subspace
            SubspaceMember.objects.create(
                subspace=subspace,
                user=request.user,
                status='active'
            )
            
            # Return the populated structure containing the new member inside 'members' list
            return response.Response(
                SubspaceSerializer(subspace, context={'request': request}).data, 
                status=status.HTTP_201_CREATED
            )
        return response.Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class SubspaceDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, household_id, subspace_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        try:
            subspace = Subspace.objects.get(id=subspace_id, household_id=household_id)
        except Subspace.DoesNotExist:
            return response.Response(
                {'error': 'Subspace not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        # Release all associated spaces back to the common household area before deletion
        HouseholdSpace.objects.filter(subspace=subspace).update(subspace=None)
        subspace.delete()
        return response.Response({'message': 'Subspace deleted, spaces released to common'})


class AddSpaceToSubspaceView(views.APIView):
    """
    Assigns a common household space to a specific subspace.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, household_id, subspace_id):
        if not is_subspace_member(request.user, subspace_id):
            return response.Response(
                {'error': 'Not a member of this subspace'},
                status=status.HTTP_403_FORBIDDEN
            )
        space_id = request.data.get('space_id')
        try:
            space = HouseholdSpace.objects.get(id=space_id, household_id=household_id)
        except HouseholdSpace.DoesNotExist:
            return response.Response(
                {'error': 'Space not found'},
                status=status.HTTP_404_NOT_FOUND
            )
        if space.subspace is not None:
            return response.Response(
                {'error': 'Space already assigned to a subspace, release it first'},
                status=status.HTTP_400_BAD_REQUEST
            )
        space.subspace_id = subspace_id
        space.save()
        return response.Response(
            HouseholdSpaceSerializer(space).data,
            status=status.HTTP_200_OK
        )


# ─── JOIN REQUEST VIEWS ────────────────────────────────────

class SubspaceInviteView(views.APIView):
    """
    Allows an existing subspace member to invite another user to the subspace.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, household_id, subspace_id):
        if not is_subspace_member(request.user, subspace_id):
            return response.Response(
                {'error': 'Not a member of this subspace'},
                status=status.HTTP_403_FORBIDDEN
            )
        invited_user_id = request.data.get('user_id')
        if not invited_user_id:
            return response.Response(
                {'error': 'user_id required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Check if the user is already a member of the subspace
        if SubspaceMember.objects.filter(subspace_id=subspace_id, user_id=invited_user_id).exists():
            return response.Response(
                {'error': 'User already a member'},
                status=status.HTTP_400_BAD_REQUEST
            )
        # Check if a pending join request or invitation already exists for this user
        if SubspaceJoinRequest.objects.filter(
            subspace_id=subspace_id,
            requested_by_id=invited_user_id,
            status='pending'
        ).exists():
            return response.Response(
                {'error': 'Request already pending'},
                status=status.HTTP_400_BAD_REQUEST
            )
        join_request = SubspaceJoinRequest.objects.create(
            subspace_id=subspace_id,
            requested_by_id=invited_user_id,
            invited_by=request.user,
        )
        return response.Response(
            SubspaceJoinRequestSerializer(join_request).data,
            status=status.HTTP_201_CREATED
        )


class SubspaceJoinRequestView(views.APIView):
    """
    Allows a household member to request to join a specific subspace.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, household_id, subspace_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        if SubspaceMember.objects.filter(subspace_id=subspace_id, user=request.user).exists():
            return response.Response(
                {'error': 'Already a member'},
                status=status.HTTP_400_BAD_REQUEST
            )
        if SubspaceJoinRequest.objects.filter(
            subspace_id=subspace_id,
            requested_by=request.user,
            status='pending'
        ).exists():
            return response.Response(
                {'error': 'Request already pending'},
                status=status.HTTP_400_BAD_REQUEST
            )
        join_request = SubspaceJoinRequest.objects.create(
            subspace_id=subspace_id,
            requested_by=request.user,
            invited_by=None,
        )
        return response.Response(
            SubspaceJoinRequestSerializer(join_request).data,
            status=status.HTTP_201_CREATED
        )


class SubspaceRespondRequestView(views.APIView):
    """
    Case 1 (Invite): invited person le accept/decline, any subspace member le cancel
    Case 2 (Self request): any subspace member le accept/decline, requester afai cancel
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, household_id, subspace_id, request_id):
        if not is_household_member(request.user, household_id):
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        try:
            join_request = SubspaceJoinRequest.objects.get(
                id=request_id,
                subspace_id=subspace_id,
                status='pending'
            )
        except SubspaceJoinRequest.DoesNotExist:
            return response.Response(
                {'error': 'Request not found or already processed'},
                status=status.HTTP_404_NOT_FOUND
            )

        # 24hr expiry check — pehile nai check garcha
        if join_request.is_expired():
            join_request.status = 'expired'
            join_request.save()
            return response.Response(
                {'error': 'Request expired'},
                status=status.HTTP_400_BAD_REQUEST
            )

        action = request.data.get('action')  # accept / decline / cancel

        if action == 'cancel':
            if join_request.invited_by is not None:
                # Invite case — any subspace member le cancel
                if not is_subspace_member(request.user, subspace_id):
                    return response.Response(
                        {'error': 'Only subspace members can cancel invitations'},
                        status=status.HTTP_403_FORBIDDEN
                    )
            else:
                # Self request case — requester afai cancel
                if join_request.requested_by != request.user:
                    return response.Response(
                        {'error': 'Only requester can cancel their own request'},
                        status=status.HTTP_403_FORBIDDEN
                    )
            join_request.status = 'declined'
            join_request.save()
            return response.Response({'message': 'Request cancelled'})

        elif action in ['accept', 'decline']:
            if join_request.invited_by is not None:
                # Invite case — sirf invited person le accept/decline
                if join_request.requested_by != request.user:
                    return response.Response(
                        {'error': 'Only invited person can accept or decline'},
                        status=status.HTTP_403_FORBIDDEN
                    )
            else:
                # Self request case — any subspace member le accept/decline
                if not is_subspace_member(request.user, subspace_id):
                    return response.Response(
                        {'error': 'Only subspace members can accept or decline join requests'},
                        status=status.HTTP_403_FORBIDDEN
                    )

            if action == 'accept':
                join_request.status = 'accepted'
                join_request.save()
                new_member = SubspaceMember.objects.create(
                    subspace_id=subspace_id,
                    user=join_request.requested_by,
                    status='active'
                )
                return response.Response({
                    'message': 'Request accepted',
                    'member': SubspaceMemberSerializer(new_member).data
                }, status=status.HTTP_200_OK)

            else:
                join_request.status = 'declined'
                join_request.save()
                return response.Response({'message': 'Request declined'})

        return response.Response(
            {'error': 'action must be accept, decline, or cancel'},
            status=status.HTTP_400_BAD_REQUEST
        ) 

class SubspaceLeaveView(views.APIView):
    """
    Allows a user to leave a subspace. If they are the last member, the subspace is deleted.
    """
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, household_id, subspace_id):
        member = SubspaceMember.objects.filter(
            subspace_id=subspace_id,
            user=request.user
        ).first()
        if not member:
            return response.Response(
                {'error': 'Not a member'},
                status=status.HTTP_400_BAD_REQUEST
            )
        # If this is the last active member, delete the subspace and release its spaces back to common
        if SubspaceMember.objects.filter(subspace_id=subspace_id, status='active').count() == 1:
            subspace = Subspace.objects.get(id=subspace_id)
            HouseholdSpace.objects.filter(subspace=subspace).update(subspace=None)
            subspace.delete()
            return response.Response({'message': 'Subspace deleted, spaces released to common'})
        member.delete()
        return response.Response({'message': 'Left subspace successfully'})