<?php

namespace App\Models;

use App\Models\OrdonnanceDetails;
use Illuminate\Database\Eloquent\Model;

class Ordonnance extends Model
{
    protected $fillable = ['dossier_medicale_id', 'medecin_id', 'date'];

    public function dossierMedicale()
    {
        return $this->belongsTo(DossierMedicale::class);
    }

    public function medecin()
    {
        return $this->belongsTo(User::class, 'medecin_id');
    }

    public function details()
    {
        return $this->hasMany(OrdonnanceDetails::class);
    }
}


