// Helper script to re-enable Google Sign-In
// Run this after configuring OAuth credentials

// Replace the _handleGoogleSignIn method in lib/screens/auth/login_screen.dart
// with this implementation:

/*
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (!success && mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final theme = Theme.of(context);
      
      String errorMessage = authProvider.errorMessage ?? 'Google sign in failed';
      
      // Check if the error is about account not found
      if (errorMessage.contains('Account not found') || errorMessage.contains('complete the signup process')) {
        // Show a more helpful message and option to go to signup
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account Not Found'),
            content: const Text(
              'No account found with this Google account. Would you like to create a new account?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/signup');
                },
                child: const Text('Create Account'),
              ),
            ],
          ),
        );
      } else {
        // Show regular error message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: theme.colorScheme.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleGoogleSignIn,
            ),
          ),
        );
      }
    }
  }
*/