if [[ -z $1 ]]; then
echo "Please specify CLI argument 'qa' or 'prod'."
elif [[ $1 == "qa" ]]; then
flutter build web --release --pwa-strategy none --web-renderer html && cp config/$1/index.html build/web/index.html
elif [[ $1 == "prod" ]]; then
flutter build web --release --pwa-strategy none --web-renderer html --dart-define=isGa4Enabled=true && cp config/$1/index.html build/web/index.html
fi

