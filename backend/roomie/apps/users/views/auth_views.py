from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import authenticate
from django.core.mail import send_mail
from django.utils.crypto import get_random_string
from django.conf import settings
import firebase_admin.auth as firebase_auth

from ..models.user import User
from ..serializers.auth_serializers import (
    SignupSerializer,
    LoginSerializer,
    ProfileSerializer,
    ForgotPasswordSerializer,
    ResetPasswordSerializer,
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

class GoogleLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        token = request.data.get('access_token')
        if not token:
            return Response(
                {'error': 'Access token required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            import requests as req
            google_response = req.get(
                f'https://www.googleapis.com/oauth2/v3/userinfo',
                headers={'Authorization': f'Bearer {token}'}
            )
            if google_response.status_code != 200:
                return Response(
                    {'error': 'Invalid Google token'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
            google_data = google_response.json()
            email = google_data.get('email')
            name = google_data.get('name', '')

            user, created = User.objects.get_or_create(
                email=email,
                defaults={
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

        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        
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


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        try:
            refresh_token = request.data.get('refresh')
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response(
                {'message': 'Logged out successfully'},
                status=status.HTTP_200_OK
            )
        except TokenError:
            return Response(
                {'error': 'Invalid token'},
                status=status.HTTP_400_BAD_REQUEST
            )


class ProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = ProfileSerializer(request.user)
        return Response(serializer.data)

    def put(self, request):
        serializer = ProfileSerializer(
            request.user,
            data=request.data,
            partial=True
        )
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ForgotPasswordView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ForgotPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            try:
                user = User.objects.get(email=email)
                reset_code = get_random_string(6, '0123456789')
                user.password_reset_code = reset_code
                user.save()

                send_mail(
                    'Roomie - Password Reset Code',
                    f'Your password reset code is: {reset_code}',
                    settings.DEFAULT_FROM_EMAIL,
                    [email],
                )
            except User.DoesNotExist:
                pass  # security: don't reveal if email exists

            return Response(
                {'message': 'Reset code sent if email exists'},
                status=status.HTTP_200_OK
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class GoogleLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        token = request.data.get('access_token')
        if not token:
            return Response(
                {'error': 'Access token required'},
                status=status.HTTP_400_BAD_REQUEST
            )
        try:
            import requests as req
            google_response = req.get(
                f'https://www.googleapis.com/oauth2/v3/userinfo',
                headers={'Authorization': f'Bearer {token}'}
            )
            if google_response.status_code != 200:
                return Response(
                    {'error': 'Invalid Google token'},
                    status=status.HTTP_401_UNAUTHORIZED
                )
            google_data = google_response.json()
            email = google_data.get('email')
            name = google_data.get('name', '')

            user, created = User.objects.get_or_create(
                email=email,
                defaults={
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

        except Exception as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
            
class ResetPasswordView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = ResetPasswordSerializer(data=request.data)
        if serializer.is_valid():
            email = serializer.validated_data['email']
            code = serializer.validated_data['code']
            new_password = serializer.validated_data['new_password']

            try:
                user = User.objects.get(email=email)
                if user.password_reset_code != code:
                    return Response(
                        {'error': 'Invalid reset code'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                user.set_password(new_password)
                user.password_reset_code = ''
                user.save()
                return Response(
                    {'message': 'Password reset successful'},
                    status=status.HTTP_200_OK
                )
            except User.DoesNotExist:
                return Response(
                    {'error': 'User not found'},
                    status=status.HTTP_400_BAD_REQUEST
                )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)