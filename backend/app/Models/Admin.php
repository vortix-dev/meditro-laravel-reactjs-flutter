<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class Admin extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = ['email', 'password'];
    protected $hidden = ['password'];

    protected $appends = ['role'];

    public function getRoleAttribute(){
        return 'admin';
    }
}