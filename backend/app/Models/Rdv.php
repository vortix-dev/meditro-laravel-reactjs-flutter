<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Rdv extends Model
{
    protected $fillable = ['medecin_id', 'user_id', 'date', 'heure', 'status'];

    public function medecin()
    {
        return $this->belongsTo(Medecin::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
