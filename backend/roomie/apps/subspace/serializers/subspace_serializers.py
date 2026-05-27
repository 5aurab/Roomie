from rest_framework import serializers
from ..models import HouseholdSpace, Subspace, SubspaceMember, SubspaceJoinRequest

class HouseholdSpaceSerializer(serializers.ModelSerializer):
    is_common = serializers.SerializerMethodField()

    class Meta:
        model =HouseholdSpace
        fields = ['id', 'name', 'subspace', 'is_common']
        read_only_fields = ['household', 'is_common']

    def get_is_common(self, obj):
        return obj.subspace is None
        
class SubspaceSerializer(serializers.ModelSerializer):
    
    class Meta:
        model = Subspace
        fields = ['id', 'name', 'is_individual']
        read_only_fields = ['household']

    def get_members_count(self, obj):
        return obj.members.filter(status='active').count()
        
class SubspaceMemberSerializer(serializers.ModelSerializer):
    user_display_name = serializers.CharField(source='user.display_name', read_only=True)
    user_email = serializers.EmailField(source='user.email', read_only=True)
    user_status_vibe = serializers.CharField(source='user.status_vibe', read_only=True) 

    class Meta:
        model = SubspaceMember
        fields = ['id', 'user', 'subspace', 'user_display_name', 'user_email', 'user_status_vibe', 'status']
        read_only_fields = ['status']       

class SubspaceJoinRequestSerializer(serializers.ModelSerializer):
    requested_by_name = serializers.CharField(source='requested_by.display_name', read_only=True)
    invited_by_name = serializers.CharField(source='invited_by.display_name', read_only=True)

    class Meta:
        model = SubspaceJoinRequest
        fields = ['id', 'subspace', 'requested_by', 'invited_by', 'status', 'requested_by_name', 'invited_by_name', 'created_at', 'expires_at']
        read_only_fields = ['requested_by', 'invited_by', 'status', 'created_at', 'expires_at']
