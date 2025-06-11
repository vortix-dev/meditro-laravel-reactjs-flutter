<?php

namespace App\Http\Controllers;

use App\Models\DossierMedicale;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class DossierMedicaleController extends Controller
{
     public function index($id)
    {
        $dossiers = DossierMedicale::where('medecin_id' , $id)->with(['medecin', 'user','ordonnance'])->get();

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
    public function show($id)
    {
        $dm = DossierMedicale::find($id);

        return response()->json([
            'status' => 200,
            'data' => $dm
        ],200);
    }
    /**
     * تحديث ملف طبي // Update the specified medical record
     */
    public function update(Request $request, $id)
{
    $dossierMedicale = DossierMedicale::where('user_id', $id)->first();

    if (!$dossierMedicale) {
        return response()->json([
            'status' => 404,
            'message' => 'Dossier médical non trouvé pour cet utilisateur.',
        ], 404);
    }

    $request->validate([
        'diagnostic' => 'sometimes|string|max:255',
        'groupe_sanguin' => 'sometimes|in:A+,A-,B+,B-,AB+,AB-,O+,O-',
        'poids' => 'sometimes|numeric|min:0',
        'taille' => 'sometimes|numeric|min:0',
    ]);

    if ($request->filled('diagnostic')) {
        $dossierMedicale->diagnostic = $request->diagnostic;
    }

    if ($request->filled('groupe_sanguin')) {
        $dossierMedicale->groupe_sanguin = $request->groupe_sanguin;
    }

    if ($request->filled('poids')) {
        $dossierMedicale->poids = $request->poids;
    }

    if ($request->filled('taille')) {
        $dossierMedicale->taille = $request->taille;
    }

    $dossierMedicale->save();

    return response()->json([
        'status' => 200,
        'message' => 'Fiche médicale mise à jour avec succès.',
        'data' => $dossierMedicale,
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

    public function getDossier($id)
    {
        $dossiers = DossierMedicale::where('user_id' , $id)->with(['medecin', 'user','ordonnance'])->get();

        return response()->json([
            'status' => 200,
            'data' => $dossiers,
        ], 200);
    }
}
