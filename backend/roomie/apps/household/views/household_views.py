from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from ..models.household import Household, HouseholdMember
from ..serializers.household_serializers import (
    HouseholdSerializer,
    JoinHouseholdSerializer,
    HouseholdMemberSerializer,
)


class CreateHouseholdView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = HouseholdSerializer(data=request.data)
        if serializer.is_valid():
            household = serializer.save(created_by=request.user)
            HouseholdMember.objects.create(
                household=household,
                user=request.user,
            )
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class JoinHouseholdView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = JoinHouseholdSerializer(data=request.data)
        if serializer.is_valid():
            join_code = serializer.validated_data['join_code']
            household = Household.objects.get(join_code=join_code)

            if HouseholdMember.objects.filter(
                household=household,
                user=request.user
            ).exists():
                return Response(
                    {'error': 'Already a member of this household'},
                    status=status.HTTP_400_BAD_REQUEST
                )

            member = HouseholdMember.objects.create(
                household=household,
                user=request.user,
                move_in_date=serializer.validated_data.get('move_in_date')
            )
            return Response(
                HouseholdMemberSerializer(member).data,
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class HouseholdDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        memberships = HouseholdMember.objects.filter(user=request.user)
        households = [m.household for m in memberships]
        serializer = HouseholdSerializer(households, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


class LeaveHouseholdView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, household_id):
        try:
            member = HouseholdMember.objects.get(
                household_id=household_id,
                user=request.user
            )
        except HouseholdMember.DoesNotExist:
            return Response(
                {'error': 'You are not a member of this household'},
                status=status.HTTP_400_BAD_REQUEST
            )

        remaining = HouseholdMember.objects.filter(
            household_id=household_id
        ).count()

        if remaining == 1:
            member.household.delete()
            return Response(
                {'message': 'Household deleted as you were the last member'},
                status=status.HTTP_200_OK
            )

        member.delete()
        return Response(
            {'message': 'Left household successfully'},
            status=status.HTTP_200_OK
        )