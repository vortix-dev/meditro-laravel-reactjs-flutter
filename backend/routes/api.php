<?php

use App\Http\Controllers\AssistanceController;
use App\Http\Controllers\Auth\AuthenticatedSessionController;
use App\Http\Controllers\Auth\RegisteredUserController;
use App\Http\Controllers\DossierMedicaleController;
use App\Http\Controllers\MedecinController;
use App\Http\Controllers\OrdonnanceController;
use App\Http\Controllers\RdvController;
use App\Http\Controllers\ServiceController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [RegisteredUserController::class, 'store'])
    ->middleware('guest')
    ->name('register');

Route::post('/login', [AuthenticatedSessionController::class, 'store'])
    ->middleware('guest')
    ->name('login');

Route::post('/logout', [AuthenticatedSessionController::class, 'destroy'])
    ->middleware('auth:sanctum')
    ->name('logout');

Route::middleware(['auth:sanctum', 'abilities:admin'])->prefix('admin')->group(static function(){
    Route::apiResource('services',ServiceController::class);
    Route::get('medecins', [MedecinController::class , 'index']);
    Route::post('medecins', [MedecinController::class , 'store']);
    Route::delete('medecins/{id}', [MedecinController::class , 'destroy']);
    Route::get('assistance', [AssistanceController::class , 'index']);
    Route::post('assistance', [AssistanceController::class , 'store']);
    Route::delete('assistance/{id}', [AssistanceController::class , 'destroy']);
});
Route::middleware(['auth:sanctum', 'abilities:medecin'])->prefix('medecin')->group(static function(){
    Route::post('dossier-medicale',[DossierMedicaleController::class , 'store']);
    Route::put('dossier-medicale/{id}',[DossierMedicaleController::class , 'update']);
    Route::get('dossier-medicale/{id}',[DossierMedicaleController::class , 'show']);
    Route::delete('dossier-medicale/{id}',[DossierMedicaleController::class , 'destroy']);
    Route::put('profile-update/{id}', [MedecinController::class , 'update']);
    Route::get('all-my-rdv' , [RdvController::class , 'getMyRdvs']);
    Route::get('all-my-patient' , [RdvController::class,'getMyPatients']);
    Route::get('get-dossier/{id}',[DossierMedicaleController::class, 'getDossier']);
    Route::get('profile', [MedecinController::class , 'show']);
    Route::put('update-rdv/{id}' , [RdvController::class , 'UpdateStatus']);
    Route::get('/ordonnances/{id}', [OrdonnanceController::class, 'index']);
    Route::post('/ordonnances', [OrdonnanceController::class, 'store']);
    Route::delete('/ordonnances/{id}', [OrdonnanceController::class, 'destroy']);
    Route::get('/ordonnances/{id}/pdf', [OrdonnanceController::class, 'generatePdf']);
});
Route::middleware(['auth:sanctum', 'abilities:assistance'])->prefix('assistance')->group(static function(){
    Route::put('profile-update/{id}', [AssistanceController::class , 'update']);
    Route::get('all-rdv' , [RdvController::class , 'index']);
    Route::get('profile', [AssistanceController::class , 'show']);
    Route::put('update-rdv/{id}' , [RdvController::class , 'update']);
});
Route::middleware(['auth:sanctum', 'abilities:web'])->prefix('user')->group(static function(){
    Route::post('create-rdv' , [RdvController::class , 'store']);
    Route::get('all-my-rdv' , [RdvController::class , 'getMyRdv']);
    Route::get('dossier-medicale',[DossierMedicaleController::class , 'index']);
    Route::post('cancel-rdv/{id}' , [RdvController::class , 'CancelRdv']);
    Route::get('dossier-medical',[DossierMedicaleController::class , 'getMyDossier']);
    Route::get('/ordonnances/{id}/pdf', [OrdonnanceController::class, 'myOrdonnances']);
    Route::get('medecins/{id}',[MedecinController::class,'getMedecinByService']);
    Route::get('/available-times', [RdvController::class, 'getAvailableTimes']);
});
Route::get('services', [ServiceController::class , 'index']);
Route::get('medecins', [MedecinController::class , 'index']);


