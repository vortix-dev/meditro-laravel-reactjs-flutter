<?php

namespace App\Http\Controllers\Auth;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Http\JsonResponse;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;
use App\Http\Requests\Auth\LoginRequest;

class AuthenticatedSessionController extends Controller
{
  
    public function store(LoginRequest $request): JsonResponse
    {
        $request->authenticate();

        $guards = ['web', 'medecin', 'admin', 'assistance'];

        $user = null;
        foreach ($guards as $guard) {
            $currentGuard = Auth::guard($guard);
            if ($currentGuard->check()) {
                $user = $currentGuard->user();break;
            }
        };
        if (!$user) {
            return response()->json(['message' => 'Access Denied'], 401);
        }

        $token = $user->createToken('api', [$guard])->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token,
        ],200);
    }

   
    public function destroy(Request $request): Response
    {
        $guards = ['web', 'medecin', 'admin' , 'assistance'];
        $user = null;
        foreach ($guards as $guard) {
        $currentGuard = Auth::guard($guard);
        if ($currentGuard->check()) {
            $user = $currentGuard->user();
            break;
        }
        }
        
        $request->user()->currentAccessToken()->delete();
        return response()->noContent();
    }
}