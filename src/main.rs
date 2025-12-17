use tracing::{info, Level};
use tracing_subscriber::FmtSubscriber;

#[tokio::main]
async fn main() {
    // Configurar logs
    let subscriber = FmtSubscriber::builder()
        .with_max_level(Level::INFO)
        .finish();
    tracing::subscriber::set_global_default(subscriber)
        .expect("setting default subscriber failed");

    info!("🚀 TL-Engine Iniciado correctamente");
    
    // Aquí iría el loop principal del servidor
    // Por ahora simulamos trabajo
    info!("Esperando tareas...");
}
