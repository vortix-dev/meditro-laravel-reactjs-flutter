<?php

namespace App\Http\Controllers;

use App\Models\Service;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ServiceController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $services = Service::all();
        return response()->json([
            'status' => 200,
            'data' => $services,
        ], 200);
    }

    /**
     * Store a newly created resource in storage.
     */
    
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'img' => 'required|image|mimes:jpeg,png,jpg,gif|max:20480',
        ]);

        $data = $request->only('name');

        if ($request->hasFile('img')) {
            // تخزين الصورة في مجلد public/uploads/services داخل storage
            $path = $request->file('img')->store('uploads/services', 'public');

            // إنشاء رابط مباشر للصورة
            $data['img'] = asset('storage/' . $path);
        }

        $service = Service::create($data);

        return response()->json([
            'status' => 200,
            'message' => 'Service created successfully.',
            'data' => $service
        ], 200);
    }

    /**
     * Display the specified resource.
     */
    public function show(Service $service)
    {
        return response()->json([
            'status' => 200,
            'data' => $service,
        ], 200);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Service $service)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'img' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:20480',
        ]);

        $data = $request->only('name');

        if ($request->hasFile('img')) {
            if ($service->img) {
                Storage::disk('public')->delete(str_replace(Storage::url(''), '', $service->img));
            }
            $data['img'] = $request->file('img')->store('uploads/services', 'public');
        }

        $service->update($data);

        return response()->json([
            'status' => 200,
            'message' => 'Service updated successfully.',
        ], 200);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Service $service)
    {
        if ($service->img) {
            Storage::disk('public')->delete(str_replace(Storage::url(''), '', $service->img));
        }
        $service->delete();

        return response()->json([
            'status' => 204,
            'message' => 'Service deleted successfully.',
        ], 204);
    }
}