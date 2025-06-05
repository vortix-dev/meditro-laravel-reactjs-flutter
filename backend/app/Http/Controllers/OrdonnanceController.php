<?php

namespace App\Http\Controllers;

use App\Models\Ordonnance;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class OrdonnanceController extends Controller
{
    public function index($id)
    {
        return Ordonnance::where('dossier_medicale_id',$id)->with(['details', 'dossierMedicale.patient', 'medecin'])->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'dossier_medicale_id' => 'required|exists:dossier_medicales,id',
            'medecin_id' => 'required|exists:users,id',
            'date' => 'required|date',
            'medicaments' => 'required|array',
        ]);

        $ordonnance = Ordonnance::create($request->only(['dossier_medicale_id', 'medecin_id', 'date']));

        foreach ($request->medicaments as $med) {
            $ordonnance->details()->create($med);
        }

        return response()->json($ordonnance->load('details'), 201);
    }

    public function generatePdf($id)
    {
        $ordonnance = Ordonnance::with(['details', 'dossierMedicale.user', 'medecin'])->findOrFail($id);

        $html = '
            <html>
            <head>
                <style>
                    body { font-family: sans-serif; }
                    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                    th, td { border: 1px solid #333; padding: 8px; text-align: left; }
                </style>
            </head>
            <body>
                <h1>Ordonnance Médicale</h1>
                <p><strong>Médecin:</strong> ' . $ordonnance->dossierMedicale->medecin->name . '</p>
                <p><strong>Patient:</strong> ' . $ordonnance->dossierMedicale->user->name . '</p>
                <p><strong>Date:</strong> ' . $ordonnance->date . '</p>

                <h3>Médicaments</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Médicament</th>
                            <th>Dosage</th>
                            <th>Fréquence</th>
                            <th>Durée</th>
                        </tr>
                    </thead>
                    <tbody>';

        foreach ($ordonnance->details as $detail) {
            $html .= '
                <tr>
                    <td>' . $detail->medicament . '</td>
                    <td>' . $detail->dosage . '</td>
                    <td>' . $detail->frequence . '</td>
                    <td>' . $detail->duree . '</td>
                </tr>';
        }

        $html .= '
                    </tbody>
                </table>
            </body>
            </html>';

        // 🔹 توليد PDF من HTML مباشرة
        $pdf = Pdf::loadHTML($html);

        return response($pdf->output(), 200)
            ->header('Content-Type', 'application/pdf')
            ->header('Content-Disposition', 'inline; filename="ordonnance-'.$ordonnance->id.'.pdf"');
    }

    // 🔹 حذف وصفة
    public function destroy($id)
    {
        $ordonnance = Ordonnance::findOrFail($id);
        $ordonnance->delete();
        return response()->json(['message' => 'Ordonnance supprimée']);
    }

    public function myOrdonnances($id)
    {
        $ordonnance = Ordonnance::with(['details', 'dossierMedicale.user', 'medecin'])->findOrFail($id);

        $html = '
            <html>
            <head>
                <style>
                    body { font-family: sans-serif; }
                    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
                    th, td { border: 1px solid #333; padding: 8px; text-align: left; }
                </style>
            </head>
            <body>
                <h1>Ordonnance Médicale</h1>
                <p><strong>Médecin:</strong> ' . $ordonnance->dossierMedicale->medecin->name . '</p>
                <p><strong>Patient:</strong> ' . $ordonnance->dossierMedicale->user->name . '</p>
                <p><strong>Date:</strong> ' . $ordonnance->date . '</p>

                <h3>Médicaments</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Médicament</th>
                            <th>Dosage</th>
                            <th>Fréquence</th>
                            <th>Durée</th>
                        </tr>
                    </thead>
                    <tbody>';

        foreach ($ordonnance->details as $detail) {
            $html .= '
                <tr>
                    <td>' . $detail->medicament . '</td>
                    <td>' . $detail->dosage . '</td>
                    <td>' . $detail->frequence . '</td>
                    <td>' . $detail->duree . '</td>
                </tr>';
        }

        $html .= '
                    </tbody>
                </table>
            </body>
            </html>';

        // 🔹 توليد PDF من HTML مباشرة
        $pdf = Pdf::loadHTML($html);

        return response($pdf->output(), 200)
            ->header('Content-Type', 'application/pdf')
            ->header('Content-Disposition', 'inline; filename="ordonnance-'.$ordonnance->id.'.pdf"');
    }
}
