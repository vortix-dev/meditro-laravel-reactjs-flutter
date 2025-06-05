<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DossierMedicale extends Model
{
    protected $fillable = [
        'medecin_id',
        'user_id',
        'diagnostic',
        'groupe_sanguin',
        'poids',
        'taille',
    ];

    public function medecin()
    {
        return $this->belongsTo(Medecin::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function ordonnance()
    {
        return $this->hasMany(Ordonnance::class);
    }

}

