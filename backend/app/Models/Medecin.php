<?php

namespace App\Models;

use Laravel\Sanctum\HasApiTokens;
use Illuminate\Foundation\Auth\User as Authenticatable;

class Medecin extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = ['name', 'email', 'password', 'service_id'];
    protected $hidden = ['password'];

    protected $appends = ['role'];

    public function getRoleAttribute(){
        return 'medecin';
    }

   
}