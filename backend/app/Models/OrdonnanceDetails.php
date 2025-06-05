<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrdonnanceDetails extends Model
{
    protected $fillable = ['ordonnance_id', 'medicament', 'dosage', 'frequence', 'duree'];

    public function ordonnance()
    {
        return $this->belongsTo(Ordonnance::class);
    }
}


