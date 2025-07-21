<?php

namespace App\Http\Controllers;

use App\Models\Rdv;
use App\Models\User;
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
            'heure' => [
                'required',
                'regex:/^([0-1][0-9]|2[0-3]):00$/', // Validates HH:00 format
                function ($attribute, $value, $fail) {
                    $hour = (int) explode(':', $value)[0];
                    if ($hour < 8 || $hour > 15) { // Allow 8:00 to 15:00 for 1-hour slots ending at 16:00
                        $fail('The time must be between 08:00 and 15:00.');
                    }
                },
            ],
            'status' => 'in:pending',
        ]);

        // Check if the time slot is already booked
        $existingRdv = Rdv::where('medecin_id', $validated['medecin_id'])
            ->where('date', $validated['date'])
            ->where('heure', $validated['heure'])
<<<<<<< HEAD
            ->whereIn('status',['pending','confirmed'])
=======
>>>>>>> eb200946f82597c694de459c1d01cdbea5787bf8
            ->exists();

        if ($existingRdv) {
            return response()->json([
                'status' => 400,
                'message' => 'This time slot is already booked.',
            ], 400);
        }

        $validated['user_id'] = auth()->id();

        $rdv = Rdv::create($validated);

        return response()->json([
            'status' => 200,
            'message' => 'Appointment has been sent',
        ], 200);
    }

    // New method to fetch available time slots
    public function getAvailableTimes(Request $request)
    {
        $validated = $request->validate([
            'medecin_id' => 'required|exists:medecins,id',
            'date' => 'required|date|after:today',
        ]);

        $bookedTimes = Rdv::where('medecin_id', $validated['medecin_id'])
            ->where('date', $validated['date'])
            ->pluck('heure')
            ->toArray();

        $allTimes = [];
        for ($hour = 8; $hour <= 15; $hour++) {
            $time = sprintf('%02d:00', $hour);
            $allTimes[] = $time;
        }

        $availableTimes = array_diff($allTimes, $bookedTimes);

        return response()->json([
            'status' => 200,
            'times' => array_values($availableTimes),
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
        $rdv = Rdv::findOrFail($id);

        $validated = $request->validate([
            'status' => 'required|in:confirmed,cancelled',
        ]);

        $rdv->update([
            'status' => $validated['status'],
        ]);

        return response()->json([
            'status' => 200,
            'message' => 'Appointment status updated successfully',
        ], 200);
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
        $patientIds = Rdv::where('medecin_id', auth()->id())
                        ->where('status', 'done')
                        ->pluck('user_id') // جمع كل user_id
                        ->unique(); // حذف التكرارات

        $patients = User::whereIn('id', $patientIds)->with(['rdv'])->get();

        return response()->json([
            'status' => 200,
            'data' => $patients,
        ], 200);
    }

}