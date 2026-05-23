from rest_framework import serializers
from ..models.household import Household, HouseholdMember

class HouseholdSerializer(serializers.ModelSerializer):
    members_count = serializers.SerializerMethodField()

    class Meta:
        model = Household
        fields = [
            'id',
            'name',
            'address',
            'no_of_rooms',
            'move_in_date',
            'join_code',
            'created_by',
            'created_at',
            'members_count',
        ]
        read_only_fields = ['join_code', 'created_by', 'created_at']

    def get_members_count(self, obj):
        return obj.members.count()


class JoinHouseholdSerializer(serializers.Serializer):
    join_code = serializers.CharField(max_length=8)
    move_in_date = serializers.DateField(required=False)

    def validate_join_code(self, value):
        try:
            Household.objects.get(join_code=value.upper())
        except Household.DoesNotExist:
            raise serializers.ValidationError("Invalid join code")
        return value.upper()


class HouseholdMemberSerializer(serializers.ModelSerializer):
    user_display_name = serializers.CharField(
        source='user.display_name',
        read_only=True
    )
    user_email = serializers.CharField(
        source='user.email',
        read_only=True
    )

    class Meta:
        model = HouseholdMember
        fields = [
            'id',
            'user',
            'user_display_name',
            'user_email',
            'role',
            'move_in_date',
            'joined_at',
        ]
        read_only_fields = ['joined_at']