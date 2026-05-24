from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    SignupView,
    LoginView,
    LogoutView,
    ProfileView,
    ForgotPasswordView,
    ResetPasswordView,
    GoogleLoginView,
)

urlpatterns = [
    path('signup/', SignupView.as_view(), name='signup'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('reset-password/', ResetPasswordView.as_view(), name='reset-password'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('google/', GoogleLoginView.as_view(), name='google-login'),
]