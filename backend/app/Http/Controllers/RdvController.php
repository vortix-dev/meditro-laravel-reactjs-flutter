<?php

namespace App\Http\Controllers;

use App\Models\Rdv;
use Illuminate\Http\Request;

class RdvController extends Controller
{


    public function index()
    {
        $rdvs = Rdv::with(['medecin', 'user'])->get();
        return response()->json([
            'status' => 200,
            'data' => $rdvs,
        ], 200);
    }


    public function store(Request $request)
    {
        $validated = $request->validate([
            'medecin_id' => 'required|exists:medecins,id',
            'date' => 'required|date|after:today',
            'status' => 'in:pending', 
        ]);

        $validated['user_id'] = auth()->id();

        $rdv = Rdv::create($validated);

        return response()->json([
            'status' => 200,
            'message' => ' Appointment has been sent', // Appointment has been sent
        ], 200);
    }

    public function show(Rdv $rdv)
    {
        return response()->json([
            'status' => 200,
            'data' => $rdv->load(['medecin', 'user']),
        ], 200);
    }

    public function update(Request $request, $id)
    {
        $rdv = Rdv::find($id);

        $validated = $request->validate([
            'status' => 'required|in:confirmed,cancelled',
            'date' => 'nullable|date|after:today',
            'heure' => 'nullable|date_format:H:i:s',
        ]);

        $updateData = ['status' => $validated['status']];

        if (isset($validated['date'])) {
            $updateData['date'] = $validated['date'];
        }

        if (isset($validated['heure'])) {
            $updateData['heure'] = $validated['heure'];
        }

        $rdv->update($updateData);

        return response()->json([
            'status' => 200,
            'message' => 'Appointment status updated successfully',
        ]);
    }


    public function getMyRdv()
    {
        $rdvs = Rdv::where('user_id', auth()->id())->with('medecin')->get();
        return response()->json([
            'status' => 200,
            'data' => $rdvs,
        ], 200);
    }

    public function CancelRdv($id)
    {
        
        $rdv = Rdv::findOrFail($id);

        if ($rdv->user_id !== auth()->id()) {
            return response()->json([
                'status' => 403,
                'message' => 'Unauthorized',
            ], 403);
        }

        if ($rdv->status !== 'pending') {
            return response()->json([
                'status' => 400,
                'message' => 'Cannot deleted an appointment that is not pending',
            ], 400);
        }

        $rdv->delete();

        return response()->json([
            'status' => 200,
            'message' => 'Appointment deleted successfully', 
        ], 200);
    }

    public function UpdateStatus(Request $request,$id) 
    {
        $rdv = Rdv::find($id);

        $validated = $request->validate([
            'status' => 'required|in:done,cancelled',
        ]);
        
        $rdv->update([
            'status' => $validated['status'],
        ]);

        return response()->json([
            'status' => 200,
            'message' => 'Appointment status updated successfully', 
        ], 200);
    }

    public function getMyRdvs()
    {
        $rdvs = Rdv::where('medecin_id', auth()->id())
                    ->whereIn('status', ['confirmed', 'done'])
                    ->with('user') 
                    ->get();
        return response()->json([
            'status' => 200,
            'data' => $rdvs,
        ], 200);
    }

    public function getMyPatients()
    {
        $rdvs = Rdv::where('medecin_id', auth()->id())
                    ->where('status','done')
                    ->with('user') 
                    ->get();
        return response()->json([
            'status' => 200,
            'data' => $rdvs,
        ], 200);
    }
}