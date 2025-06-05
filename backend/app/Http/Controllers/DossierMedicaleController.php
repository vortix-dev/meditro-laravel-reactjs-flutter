<?php

namespace App\Http\Controllers;

use App\Models\DossierMedicale;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DossierMedicaleController extends Controller
{
     public function index()
    {
        $dossiers = DossierMedicale::where('medecin_id' , auth()->id())->with(['medecin', 'user','ordonnance'])->get();

        return response()->json([
            'status' => 200,
            'data' => $dossiers,
        ], 200);
    }


    public function store(Request $request)
    {
        $validated = $request->validate([
            'medecin_id' => 'required|exists:medecins,id',
            'user_id' => 'required|exists:users,id',
            'diagnostic' => 'required|string|max:255',
            'groupe_sanguin' => 'required|in:A+,A-,B+,B-,AB+,AB-,O+,O-',
            'poids' => 'required|numeric|min:0',
            'taille' => 'required|numeric|min:0',
        ]);

        $dossier = DossierMedicale::create($validated);

        return response()->json([
            'status' => 200,
            'data' => $dossier->load(['medecin', 'user']),
            'message' => 'Medical record created successfully', // Medical record created successfully
        ], 201);
    }

    /**
     * عرض ملف طبي محدد // Display the specified medical record
     */
    public function show(DossierMedicale $dossierMedicale)
    {
        if (!Auth::guard('assistance')->check() && !Auth::guard('medecin')->check() && $dossierMedicale->user_id !== auth()->id()) {
            return response()->json([
                'status' => 403,
                'message' => 'You are not authorized to view this medical record', // You are not authorized to view this medical record
            ], 403);
        }

        return response()->json([
            'status' => 200,
            'data' => $dossierMedicale->load(['medecin', 'user']),
        ], 200);
    }

    /**
     * تحديث ملف طبي // Update the specified medical record
     */
    public function update(Request $request, DossierMedicale $dossierMedicale)
    {
        $validated = $request->validate([
            'medecin_id' => 'sometimes|exists:medecins,id',
            'user_id' => 'sometimes|exists:users,id',
            'diagnostic' => 'sometimes|string|max:255',
            'groupe_sanguin' => 'sometimes|in:A+,A-,B+,B-,AB+,AB-,O+,O-',
            'poids' => 'sometimes|numeric|min:0',
            'taille' => 'sometimes|numeric|min:0',
        ]);

        $dossierMedicale->update($validated);

        return response()->json([
            'status' => 200,
            'data' => $dossierMedicale->load(['medecin', 'user']),
            'message' => 'Medical record updated successfully', // Medical record updated successfully
        ], 200);
    }

    /**
     * حذف ملف طبي // Remove the specified medical record
     */
    public function destroy(DossierMedicale $dossierMedicale)
    {
        $dossierMedicale->delete();

        return response()->json([
            'status' => 200,
            'message' => 'Medical record deleted successfully', // Medical record deleted successfully
        ], 200);
    }

    public function getMyDossier()
    {
        $dossiers = DossierMedicale::where('user_id' , auth()->id())->with(['medecin', 'user','ordonnance'])->get();

        return response()->json([
            'status' => 200,
            'data' => $dossiers,
        ], 200);
    }
}
