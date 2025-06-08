<?php

namespace App\Http\Controllers;

use App\Models\Assistance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AssistanceController extends Controller
{
    public function index()
    {
        $assistantes = Assistance::all();

        return response()->json([
            'status' => 200,
            'data' => $assistantes
        ], 200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string',
            'email' => 'required|string|unique:assistances,email',
            'password' => 'required|min:6',
        ]);

        $assistante = Assistance::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'status' => 200,
            'data' => $assistante
        ], 200);
    }

    public function show()
    {
        $assistante = Assistance::find(auth()->id());

        if (!$assistante) {
            return response()->json([
                'status' => 404,
                'message' => 'Assistance not found'
            ], 404);
        }

        return response()->json([
            'status' => 200,
            'data' => $assistante
        ], 200);
    }

    public function update(Request $request,$id)
    {
       $assistant = Assistance::find($id);

        if (!$assistant) {
            return response()->json(['message' => 'Non autorisé'], 401);
        }

        $request->validate([
            'name' => 'sometimes|string',
            'email' => 'sometimes|string|unique:assistances,email,' . $assistant->id,
            'password' => 'sometimes|min:6|confirmed', // Nécessite aussi password_confirmation
        ]);

        if ($request->filled('name')) {
            $assistant->name = $request->name;
        }

        if ($request->filled('email')) {
            $assistant->email = $request->email;
        }

        if ($request->filled('password')) {
            $assistant->password = Hash::make($request->password);
        }

        $assistant->save();

        return response()->json([
            'status' => 200,
            'message' => 'Profil has been updated with successfully',
            'data' => $assistant
        ], 200);

    }

    public function destroy($id)
    {
        $assistante = Assistance::find($id);

        if (!$assistante) {
            return response()->json([
                'status' => 404,
                'message' => 'Assistante not found'
            ], 404);
        }

        $assistante->delete();

        return response()->json([
            'status' => 200,
            'message' => 'Assistante has been deleted with successfully'
        ], 200);
    }
}
