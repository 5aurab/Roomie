from django.db.models import Count
from rest_framework import status, views, response, permissions
from ..models.household import Household, HouseholdMember
from ..serializers.household_serializers import (
    HouseholdSerializer,
    JoinHouseholdSerializer,
    HouseholdMemberSerializer,
)

class HouseholdDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        households = Household.objects.filter(
            members__user=request.user
        ).annotate(members_count=Count('members'))
        return response.Response(HouseholdSerializer(households, many=True).data)
    
class CreateHouseholdView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = HouseholdSerializer(data=request.data)
        if serializer.is_valid():
            household = serializer.save(created_by=request.user)
            HouseholdMember.objects.create(household=household, user=request.user)
            return response.Response(serializer.data, status=status.HTTP_201_CREATED)
        return response.Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class JoinHouseholdView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        serializer = JoinHouseholdSerializer(data=request.data)
        if serializer.is_valid():
            household = Household.objects.get(join_code=serializer.validated_data['join_code'])
            
            # Atomic membership check
            if HouseholdMember.objects.filter(household=household, user=request.user).exists():
                return response.Response({'error': 'Already a member'}, status=status.HTTP_400_BAD_REQUEST)

            member = HouseholdMember.objects.create(
                household=household, 
                user=request.user,
                move_in_date=serializer.validated_data.get('move_in_date')
            )
            return response.Response(HouseholdMemberSerializer(member).data, status=status.HTTP_201_CREATED)
        return response.Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class HouseholdMembersView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, household_id):
        # User yo household ko member ho ki xaina check
        if not HouseholdMember.objects.filter(
            household_id=household_id,
            user=request.user
        ).exists():
            return response.Response(
                {'error': 'Not a member of this household'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        members = HouseholdMember.objects.filter(
            household_id=household_id
        ).select_related('user')
        
        return response.Response(
            HouseholdMemberSerializer(members, many=True).data,
            status=status.HTTP_200_OK
        )
    

class LeaveHouseholdView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, household_id):
        member = HouseholdMember.objects.filter(household_id=household_id, user=request.user).first()
        if not member:
            return response.Response({'error': 'Not a member'}, status=status.HTTP_400_BAD_REQUEST)

        # Count total members remaining
        if HouseholdMember.objects.filter(household_id=household_id).count() == 1:
            member.household.delete()
            return response.Response({'message': 'Household deleted'}, status=status.HTTP_200_OK)

        member.delete()
        return response.Response({'message': 'Left successfully'}, status=status.HTTP_200_OK)