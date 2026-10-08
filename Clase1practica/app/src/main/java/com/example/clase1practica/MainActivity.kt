package com.example.clase1practica

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.example.clase1practica.ui.theme.Clase1practicaTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Clase1practicaTheme {
                PantallaOrigen()
            }
        }
    }
}

// @Composable indica que esta función dibuja una interfaz (igual que un componente)
@Composable
fun PantallaOrigen() {
    // LocalContext es necesario en Compose para poder ejecutar el Intent
    val contexto = LocalContext.current
    val mensajeCool = "¡El backend aprueba este mensaje \uD83D\uDE80!"

    // Column funciona como un contenedor Flexbox en columna para centrar el contenido
    Column(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Button(onClick = {
            // Empaquetamos el mensaje y disparamos el viaje a SegundaActivity
            val intent = Intent(contexto, SegundaActivity::class.java)
            intent.putExtra("CLAVE_TEXTO", mensajeCool)
            contexto.startActivity(intent)
        }) {
            Text("Enviar Mensaje Secreto")
        }
    }
}