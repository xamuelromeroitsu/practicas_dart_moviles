package com.example.clase1practica

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.example.clase1practica.ui.theme.Clase1practicaTheme

class SegundaActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // 1. Aquí "desempaquetamos" el mensaje que viene en el Intent desde MainActivity
        // Usamos la misma llave: "CLAVE_TEXTO". El "?: " es por si acaso llega vacío.
        val textoRecibido = intent.getStringExtra("CLAVE_TEXTO") ?: "No llegó ningún mensaje"

        setContent {
            Clase1practicaTheme {
                // 2. Dibujamos la interfaz de esta segunda pantalla
                Column(
                    modifier = Modifier.fillMaxSize(),
                    verticalArrangement = Arrangement.Center,
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    Text(text = "El mensaje secreto es:")
                    Text(text = textoRecibido) // Mostramos la variable que extrajimos
                }
            }
        }
    }
}