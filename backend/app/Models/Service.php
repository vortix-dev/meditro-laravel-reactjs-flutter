<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Service extends Model
{
    protected $fillable = ['name', 'img'];

    public function getImgAttribute($value)
    {
        return $value ? url(Storage::url($value)) : null;
    }
}
