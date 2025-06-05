<?php

namespace App\Http\Controllers;

use App\Models\Medecin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class MedecinController extends Controller
{
     public function index()
    {
        $medecins = Medecin::all();
        return response()->json([
            'status' => 200,
            'data' => $medecins
        ],200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'service_id' => 'required|exists:services,id',
            'name' => 'required|string',
            'email' => 'required|string|unique:medecins,email',
            'password' => 'required|min:6',
        ]);

        $medecin = Medecin::create([
            'service_id' => $request->service_id,
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        return response()->json([
            'status' => 200,
            'data' => $medecin
        ], 200);
    }

    public function show()
    {
        $medecin = Medecin::find(auth()->id());

        if (!$medecin) {
            return response()->json([
                'status' => 404,
                'message' => 'Assistance not found'
            ], 404);
        }

        return response()->json([
            'status' => 200,
            'data' => $medecin
        ], 200);
    }

    public function update(Request $request)
    {
        $medecin = Auth::guard('medecin')->user();

        if (!$medecin) {
            return response()->json(['message' => 'Non autorisé'], 401);
        }

        $request->validate([
            'name' => 'sometimes|string',
            'email' => 'sometimes|string|unique:medecins,email,' . $medecin->id,
            'password' => 'sometimes|min:6|confirmed', // Nécessite password_confirmation
        ]);

        if ($request->filled('name')) {
            $medecin->name = $request->name;
        }

        if ($request->filled('email')) {
            $medecin->email = $request->email;
        }

        if ($request->filled('password')) {
            $medecin->password = Hash::make($request->password);
        }

        $medecin->save();

        return response()->json([
            'status' => 200,
            'message' => 'Profil mis à jour avec succès.',
            'data' => $medecin
        ], 200);
    }


    public function destroy($id)
    {

        $medecin = Medecin::find($id);

        if (!$medecin) {
            return response()->json([
                'status' => 404,
                'message' => 'Médecin introuvable'
            ], 404);
        }

        $medecin->delete();

        return response()->json([
            'status' => 200,
            'message' => 'Médecin supprimé avec succès'
        ],200);
    }

    
}
