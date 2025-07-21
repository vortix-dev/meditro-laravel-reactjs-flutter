<?php

namespace App\Http\Controllers;

use App\Models\Ordonnance;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Request;

class OrdonnanceController extends Controller
{
    public function index($id)
    {
        return Ordonnance::where('dossier_medicale_id', $id)->with(['details', 'dossierMedicale.patient', 'medecin'])->get();
    }

    public function store(Request $request)
    {
        $request->validate([
            'dossier_medicale_id' => 'required|exists:dossier_medicales,id',
            'medecin_id' => 'required|exists:medecins,id',
            'date' => 'required|date',
            'medicaments' => 'required|array',
        ]);

        $ordonnance = Ordonnance::create($request->only(['dossier_medicale_id', 'medecin_id', 'date']));

        foreach ($request->medicaments as $med) {
            $ordonnance->details()->create($med);
        }

        return response()->json($ordonnance->load('details'), 201);
    }

    private function generateOrdonnanceHtml($ordonnance)
    {
        // تحويل الصورة إلى Base64
        $logoPath = public_path('assets/logo.png');
        $logoBase64 = file_exists($logoPath) ? base64_encode(file_get_contents($logoPath)) : '';
        $logoUrl = $logoBase64 ? 'data:image/png;base64,' . $logoBase64 : 'https://via.placeholder.com/100x50?text=Logo';

        $html = '
            <html>
            <head>
                <meta charset="UTF-8">
                <title>Ordonnance Médicale</title>
                <style>
                    body {
                        font-family: \'Arial\', sans-serif;
                        background-color: #f5f7fa;
                        margin: 0;
                        padding: 20px;
                        color: #333;
                    }
                    .container {
                        max-width: 800px;
                        margin: 0 auto;
                        background: #ffffff;
                        border-radius: 10px;
                        box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
                        padding: 30px;
                        border-top: 5px solid #2c3e50;
                    }
                    .header {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 20px;
                    }
                    .header img {
                        max-width: 100px;
                    }
                    .header .clinic-info {
                        text-align: right;
                    }
                    .header .clinic-info h2 {
                        margin: 0;
                        color: #2c3e50;
                        font-size: 20px;
                    }
                    .header .clinic-info p {
                        margin: 5px 0;
                        font-size: 14px;
                        color: #7f8c8d;
                    }
                    h1 {
                        color: #2c3e50;
                        font-size: 28px;
                        text-align: center;
                        margin-bottom: 20px;
                        border-bottom: 2px solid #3498db;
                        padding-bottom: 10px;
                    }
                    p {
                        font-size: 16px;
                        margin: 10px 0;
                        color: #34495e;
                    }
                    .info-section {
                        background: #ecf0f1;
                        padding: 15px;
                        border-radius: 8px;
                        margin-bottom: 20px;
                    }
                    .info-section strong {
                        color: #2c3e50;
                    }
                    h3 {
                        color: #3498db;
                        font-size: 20px;
                        margin-top: 20px;
                        margin-bottom: 10px;
                    }
                    table {
                        width: 100%;
                        border-collapse: collapse;
                        margin-top: 20px;
                        background: #ffffff;
                        border-radius: 8px;
                        overflow: hidden;
                    }
                    th, td {
                        padding: 12px;
                        text-align: left;
                        border-bottom: 1px solid #e0e0e0;
                    }
                    th {
                        background: #3498db;
                        color: #ffffff;
                        font-weight: bold;
                    }
                    tr:nth-child(even) {
                        background: #f8fafc;
                    }
                    tr:hover {
                        background: #e8f0fe;
                    }
                    .footer {
                        text-align: center;
                        margin-top: 20px;
                        font-size: 12px;
                        color: #7f8c8d;
                    }
                    @media print {
                        body {
                            background: none;
                        }
                        .container {
                            box-shadow: none;
                            border: none;
                        }
                    }
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <img src="' . $logoUrl . '" alt="Clinic Logo">
                        <div class="clinic-info">
                            <h2>Clinique MediTro</h2>
                            <p>123 Ouled fayet, Alger</p>
                            <p>Tél: +213 699 88 77 55 | Email: contact@meditro.com</p>
                        </div>
                    </div>
                    <h1>Ordonnance Médicale</h1>
                    <div class="info-section">
                        <p><strong>Médecin:</strong> ' . htmlspecialchars($ordonnance->dossierMedicale->medecin->name) . '</p>
                        <p><strong>Patient:</strong> ' . htmlspecialchars($ordonnance->dossierMedicale->user->name) . '</p>
                        <p><strong>Date:</strong> ' . htmlspecialchars($ordonnance->date) . '</p>
                    </div>
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
                                <td>' . htmlspecialchars($detail->medicament) . '</td>
                                <td>' . htmlspecialchars($detail->dosage) . '</td>
                                <td>' . htmlspecialchars($detail->frequence) . '</td>
                                <td>' . htmlspecialchars($detail->duree) . '</td>
                            </tr>';
        }

        $html .= '
                        </tbody>
                    </table>
                    <div class="footer">
                        <p>Document généré par le système médical - Clinique MediTro</p>
                    </div>
                </div>
            </body>
            </html>';

        return $html;
    }

    public function generatePdf($id)
    {
        $ordonnance = Ordonnance::with(['details', 'dossierMedicale.user', 'medecin'])->findOrFail($id);

        $html = $this->generateOrdonnanceHtml($ordonnance);
        $pdf = Pdf::loadHTML($html);

        return response($pdf->output(), 200)
            ->header('Content-Type', 'application/pdf')
            ->header('Content-Disposition', 'inline; filename="ordonnance-' . $ordonnance->id . '.pdf"');
    }

    public function destroy($id)
    {
        $ordonnance = Ordonnance::findOrFail($id);
        $ordonnance->delete();
        return response()->json(['message' => 'Ordonnance supprimée']);
    }

    public function myOrdonnances($id)
    {
        $ordonnance = Ordonnance::with(['details', 'dossierMedicale.user', 'medecin'])->findOrFail($id);

        $html = $this->generateOrdonnanceHtml($ordonnance);
        $pdf = Pdf::loadHTML($html);

        return response($pdf->output(), 200)
            ->header('Content-Type', 'application/pdf')
            ->header('Content-Disposition', 'inline; filename="ordonnance-' . $ordonnance->id . '.pdf"');
    }
}