from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken
import firebase_admin.auth as firebase_auth

from ..models.user import User
from ..serializers.auth_serializers import (
    SignupSerializer,
    LoginSerializer,
)

def get_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


class SignupView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = SignupSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            tokens = get_tokens_for_user(user)
            return Response({
                'user': {
                    'id': user.id,
                    'email': user.email,
                    'display_name': user.display_name,
                },
                'tokens': tokens
            }, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            tokens = get_tokens_for_user(user)
            return Response({
                'user': {
                    'id': user.id,
                    'email': user.email,
                    'display_name': user.display_name,
                },
                'tokens': tokens
            }, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class GoogleAuthView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        firebase_token = request.data.get('firebase_token')
        if not firebase_token:
            return Response(
                {'error': 'Firebase token required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            decoded = firebase_auth.verify_id_token(firebase_token)
            uid = decoded['uid']
            email = decoded.get('email', '')
            name = decoded.get('name', '')

            user, created = User.objects.get_or_create(
                firebase_uid=uid,
                defaults={
                    'email': email,
                    'username': email,
                    'display_name': name,
                    'is_email_verified': True,
                }
            )
            tokens = get_tokens_for_user(user)
            return Response({
                'user': {
                    'id': user.id,
                    'email': user.email,
                    'display_name': user.display_name,
                },
                'tokens': tokens,
                'created': created
            }, status=status.HTTP_200_OK)

        except Exception:
            return Response(
                {'error': 'Invalid firebase token'},
                status=status.HTTP_401_UNAUTHORIZED
            )